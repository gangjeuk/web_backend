import { models, sequelize } from "../../models/rdbms";
import { MeiliSearch } from "meilisearch";
import { Op } from "sequelize";
import logger from "../../utils/logger";
import { ChatRoom } from "../../models/chat";

import { APIType } from "api_spec";
import * as Errors from "../../errors";
import { RequestEnum } from "api_spec/enum";
const client = new MeiliSearch({
    host: "http://127.0.0.1:7700",
    apiKey: "1zBmtAMDjgWPGLcTPAhEy-kRZv44BzxywQ1UHPkIYE0",
});

const requestSearch = client.index("request");
// requestSearch.updateFilterableAttributes(["_geo"]);
// requestSearch.updateSortableAttributes(["_geo"]);

const StudentWithCurrentSchool = models.studentwithcurrentschool;
const RequestModel = models.Request;
const ConsumerModel = models.Consumer;
const UserModel = models.User;
const StudentModel = models.Student;
const ProviderModel = models.Provider;

export const getRecommendedRequestByStudentId = async (student_id: number) => {
    const student = (
        await StudentWithCurrentSchool.findOne({
            where: { student_id: student_id },
        })
    )?.get({ plain: true });

    const coordi = JSON.parse(JSON.stringify(student?.coordinate)).coordinates;

    const searchRet = await requestSearch.search("", {
        filter: [`_geoRadius(${coordi[0]}, ${coordi[1]}, 1000000000000)`],
        sort: [`_geoPoint(${coordi[0]}, ${coordi[1]}):asc`],
    });

    return searchRet;
};

export const getRequestByRequestId = async (requestId: number) => {
    const request = await RequestModel.findOne({
        where: { request_id: requestId },
    });
    return request;
};

export const getRequestByStudentId = async (studentId: number) => {
    throw new Error("");
};

export const getRequestsByOrgnId = async (orgnId: number) => {
    const requests = await RequestModel.findAll({
        where: { orgn_id: orgnId },
    });
    return requests;
};

export const getRequestsByCorpId = async (corpId: number) => {
    const requests = await RequestModel.findAll({
        where: { corp_id: corpId },
    });
    return requests;
};

export const getRequestsByProviderUserId = async (userId: Buffer) => {
    const providerList = await ProviderModel.findAll({ where: { user_id: userId }, raw: true });

    const uniqueRequestIds = Array.from(new Set(providerList.map((val) => val.request_id)));

    const requests = await RequestModel.findAll({ where: { request_id: { [Op.in]: uniqueRequestIds } } });

    return requests;
};

export const getRequestsByUserId = async (userId: Buffer, as: "consumer" | "provider" | undefined = undefined) => {
    /**
     * We can search chatrooms to identify all users related with request
     */
    let requestIds = [] as number[];
    if (as === undefined) {
        const chatRooms = await ChatRoom.find({
            participant_ids: { $in: userId },
        });
        // request_id could be less than 0 (when deleted)
        requestIds = Array.from(new Set(chatRooms.map((room) => Math.abs(room.request_id))));
    } else if (as === "consumer") {
        const chatRooms = await ChatRoom.find({
            consumer_id: userId,
        });
        // request_id could be less than 0 (when deleted)
        requestIds = Array.from(new Set(chatRooms.map((room) => Math.abs(room.request_id))));
    } else if (as === "provider") {
        const chatRooms = await ChatRoom.find({
            $and: [{ consumer_id: { $ne: userId } }, { participant_ids: { $in: userId } }],
        });
        // request_id could be less than 0 (when deleted)
        requestIds = Array.from(new Set(chatRooms.map((room) => Math.abs(room.request_id))));
    }

    return await RequestModel.findAll({ where: { request_id: requestIds } });
};

export const updateRequestProviderIds = async (newProviderIds: Buffer[], requestId: number) => {
    try {
        const ret = await sequelize.transaction(async (t) => {
            logger.info("Start: Transaction-[Change provider ids]");
            await Promise.all(
                newProviderIds.map(async (providerId) => {
                    const student = await StudentModel.findOne({ where: { user_id: providerId }, raw: true });
                    if (!student) {
                        throw new Errors.ServiceErrorBase(
                            "updateRequestProviderIds called non-exist user - something went wrong",
                        );
                    }
                    return ProviderModel.findOrCreate({
                        where: {
                            [Op.and]: [{ request_id: requestId }, { user_id: providerId }],
                        },
                        defaults: {
                            request_id: requestId,
                            user_id: student.user_id,
                            student_id: student.student_id,
                        },
                        transaction: t,
                    });
                }),
            );

            await ProviderModel.destroy({
                where: { [Op.and]: [{ request_id: requestId }, { user_id: { [Op.notIn]: newProviderIds } }] },
                transaction: t,
            });

            logger.info("END: Transaction-[Change provider ids]");
            return newProviderIds;
        });
        return ret;
    } catch (error) {
        logger.error(`FAILED: Transaction-[Change provider ids], ${error}`);
        throw new Errors.ServiceErrorBase(`updateRequestProviderIds failed transaction: ${error}`);
    }
};

// api_spec 문서 보고 데이터 타비 맞춰서 리턴하도록 수정
export const createRequest = async (uuid: Buffer, role: "corp" | "orgn" | "normal", data) => {
    try {
        const ret = await sequelize.transaction(async (t) => {
            logger.info("Start: Transaction-[Create Request]");
            const consumerIdentity = (
                await ConsumerModel.findOne({
                    where: {
                        [Op.and]: [{ user_id: uuid }, { consumer_type: role }],
                    },
                    transaction: t,
                })
            )?.get({ plain: true });

            if (consumerIdentity === undefined) {
                throw new Error("No consumer identity exist");
            }
            // TODO: should add corp_id or orgn_id according to consumer identity
            const createdRequest = await RequestModel.create(
                {
                    ...data,
                    consumer_id: consumerIdentity.consumer_id,
                },
                { transaction: t },
            );

            logger.info(`Request created: ${createRequest}`);

            const coordinate = JSON.parse(JSON.stringify(createdRequest.dataValues.address_coordinate)).coordinates;

            const searchRet = await requestSearch.addDocuments(
                [
                    {
                        ...createdRequest.dataValues,
                        request_id: createdRequest.request_id,
                        _geo: { lat: coordinate[0], lng: coordinate[1] },
                    },
                ],
                { primaryKey: "request_id" },
            );

            const searchTask = await client.waitForTask(searchRet.taskUid);

            if (searchTask.status !== "succeeded") {
                throw new Error("No record created! " + JSON.stringify(searchTask));
            }
            logger.info("Request has been added to Search Engine");
            return createdRequest.request_id;
        });
        logger.info("End: Transaction-[Create request]");
        return ret;
    } catch (error) {
        // transaction failed
        logger.error(`Created Request Error: ${error}`);
        return undefined;
    }
};

export const updateRequestStatus = async (requestId: number, status: RequestEnum.REQUEST_STATUS_ENUM) => {
    const request = await RequestModel.findOne({
        where: { request_id: requestId },
        raw: true,
    });

    if (request === null) {
        logger.info("No such request");
        return undefined;
    }

    return await RequestModel.update({ request_status: status }, { where: { request_id: request.request_id } });
};
