import { Consumer } from "../../models/rdbms/Consumer";
import { Corporation } from "../../models/rdbms/Corporation";

export const getCorpByCorpId = async (corpId: number) => {
    return await Corporation.findOne({ where: { corp_id: corpId } });
};

export const getCorpByConsumerId = async (consumer_id: number) => {
    const consumer = await Consumer.findOne({
        where: { consumer_id },
        plain: true,
    });
    const corpId = consumer?.dataValues.corp_id;

    if (!corpId) {
        console.error("no corpid exists");
        return null;
    }

    const corpProfile = await Corporation.findOne({
        where: { corp_id: corpId },
    });

    return corpProfile;
};

export const checkUserIsCorpnWorker = async (userId: Buffer, corpId: number) => {
    const consumers = await Consumer.findAll({ where: { user_id: userId }, raw: true });

    const isWorker = consumers.find((val) => val.corp_id === corpId);

    return isWorker;
};
