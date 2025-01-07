import express from "express";

/**
 * Controller
 */
import { getUserById, updateUserByUserId } from "../../controllers/UserController";
import {
    getRequestByStudentId,
    getRequestsByProviderUserId,
    getRequestsByUserId,
} from "../../controllers/wiip/RequestController";
import { getStudentByUserId } from "../../controllers/wiip/StudentController";
/**
 * Util, types, etc..
 */
import * as Errors from "../../errors";
import { pick } from "es-toolkit";
import { filterSessionByRBAC } from "../../middleware/auth.middleware";
import { APISpec } from "api_spec";
import logger from "../../utils/logger";
import { getCorpByConsumerId, getCorpByUserId } from "../../controllers/wiip/CorporationController";

const UserRouter = express.Router();

UserRouter.get(
    "/" satisfies keyof APISpec.UserAPISpec,
    // Need login
    filterSessionByRBAC(),
    (async (req, res) => {
        logger.info("START-Get user data");
        const sessionUser = res.session!.user;

        const user = (await getUserById(sessionUser.id))?.get({ plain: true });

        if (!user) {
            throw new Errors.ServiceErrorBase("Something went wrong");
        }
        res.status(200).json({
            username: user.username ?? "",
            image: user.image ?? "",
            nationality: user.nationality,
            working_country: user.working_country,
        });
        logger.info("END-Get user data");
    }) as APISpec.UserAPISpec["/"]["get"]["handler"],
);

UserRouter.get(
    "/mypage" satisfies keyof APISpec.UserAPISpec,
    // Need login
    filterSessionByRBAC(),
    (async (req, res) => {
        logger.info("START-Get mypage data");
        const sessionUser = res.session!.user;
        const userRoles = new Set(sessionUser.roles);

        let responses: APISpec.UserAPISpec["/mypage"]["get"]["responses"]["200"] = {};

        if (userRoles.has("student")) {
            const studentProfile = (await getStudentByUserId(sessionUser.id))?.get({ plain: true });
            if (!studentProfile) {
                throw new Errors.ServiceErrorBase("Something went wrong");
            }
            const studentRequests = (await getRequestsByProviderUserId(sessionUser.id)).map((val) => {
                return pick(val.get({ plain: true }), [
                    "request_id",
                    "title",
                    "reward_price",
                    "currency",
                    "address",
                    "start_date",
                    "request_status",
                ]);
            });
            responses.student_profile = studentProfile;
            responses.student_requests = studentRequests;
        }

        if (userRoles.has("corp")) {
            const corpProfile = (await getCorpByUserId(sessionUser.id))?.get({ plain: true });
            if (!corpProfile) {
                throw new Errors.ServiceErrorBase("Something went wrong");
            }
            responses.corp_profile = corpProfile;
        }

        const userRequests = (await getRequestsByUserId(sessionUser.id)).map((val) => {
            return pick(val.get({ plain: true }), [
                "request_id",
                "title",
                "reward_price",
                "currency",
                "address",
                "start_date",
                "request_status",
            ]);
        });

        responses.user_requests = userRequests;

        res.status(200).json(responses);
        logger.info("END-Get mypage data");
    }) as APISpec.UserAPISpec["/mypage"]["get"]["handler"],
);

UserRouter.get(
    "/update" satisfies keyof APISpec.UserAPISpec,
    // Need login
    filterSessionByRBAC(),
    (async (req, res) => {
        logger.info("START-Get user data");
        const sessionUser = res.session!.user;
        const user = (await getUserById(sessionUser.id))?.get({ plain: true });

        if (!user) {
            throw new Errors.ServiceErrorBase("Something went wrong");
        }

        const updateCount = await updateUserByUserId(sessionUser.id, req.body);

        if (updateCount[0] === 0) {
            throw new Errors.ServiceErrorBase("Something went wrong");
        }
        res.status(200).json({
            username: req.body.username,
            image: req.body.image,
            nationality: req.body.nationality,
            working_country: req.body.working_country,
        });
        logger.info("END-Get user data");
    }) as APISpec.UserAPISpec["/update"]["post"]["handler"],
);

export default UserRouter;