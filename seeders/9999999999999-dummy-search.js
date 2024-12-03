"use strict";

const createDummyRequest = async (Request, requestIndex) => {
    const allRequests = await Request.findAll();

    const allDocuments = allRequests.map((requestModel) => {
        const request = requestModel.get({ plain: true });

        const coordinate = request.address_coordinate.coordinates;
        const document = {
            ...request,
            _geo: { lat: coordinate[0], lng: coordinate[1] },
        };

        return document;
    });
    requestIndex.addDocuments(allDocuments, {
        primaryKey: "request_id",
    });
};

const createDummySchool = async (School, schoolIndex) => {
    const allSchools = await School.findAll();

    const allDocuments = allSchools.map((schoolModel) => {
        const school = schoolModel.get({ plain: true });

        const document = {
            id: school.school_id,
            school_name: school.school_name,
            school_name_glb: school.school_name_glb,
            country_code: school.country_code,
            _geo: JSON.parse(JSON.stringify(school.coordinate)),
        };

        return document;
    });

    schoolIndex.addDocuments(allDocuments, {
        primaryKey: "id",
    });
};

const createDummyStudent = async (StudentWithCurrentSchool, studentIndex) => {
    const allStudents = await StudentWithCurrentSchool.findAll();

    const allDocuments = allStudents.map((studentModel) => {
        const student = studentModel.get({ plain: true });

        const coordinate = student.coordinate.coordinates;

        const document = {
            id: model.id,
            student_id: model.student_id,
            name_glb: model.name_glb,
            nationality: model.nationality,
            age: model.age,
            student_phone_number: model.student_phone_number,
            gender: model.gender,
            degree: model.degree,
            faculty: model.faculty,
            school_id: model.school_id,
            school_country_code: model.country_code,
            school_name: model.school_name,
            school_name_glb: model.school_name_glb,
            school_address: model.address,
            country_code: model.country_code,
            _geo: { lat: coordinate[0], lng: coordinate[1] },
        };

        return document;
    });

    studentIndex.addDocuments(allDocuments, {
        primaryKey: "id",
    });
};

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        const DataTypes = require("sequelize").DataTypes;

        const db = require("../models");
        const Request = db.sequelize.models.Request;
        const School = db.sequelize.models.School;
        const StudentWithCurrentSchool =
            db.sequelize.models.studentwithcurrentschool;

        const MeiliSearch = require("meilisearch").MeiliSearch;
        const client = new MeiliSearch({
            host: "http://127.0.0.1:7700",
            apiKey: "3c8f293c82e4352eed1bef7a87613bcd663130104a189e9d1ac76e05c0fcba04",
        });

        const requestIndex = client.index("request");
        const schoolIndex = client.index("school");
        const studentIndex = client.index("studentwithcurrentschool");

        requestIndex.updateFilterableAttributes(["_geo"]);
        schoolIndex.updateFilterableAttributes(["_geo"]);
        studentIndex.updateFilterableAttributes(["_geo"]);

        await createDummyRequest(Request, requestIndex);
        await createDummySchool(School, schoolIndex);
        await createDummyStudent(StudentWithCurrentSchool, studentIndex);

        return;
    },

    async down(queryInterface, Sequelize) {
        const MeiliSearch = require("meilisearch").MeiliSearch;
        const client = new MeiliSearch({
            host: "http://127.0.0.1:7700",
            apiKey: "1zBmtAMDjgWPGLcTPAhEy-kRZv44BzxywQ1UHPkIYE0",
        });
        client.deleteIndex("school");
        client.deleteIndex("request");
        client.deleteIndex("studentwithcurrentschool");
        /**
         * Add commands to revert seed here.
         *
         * Example:
         * await queryInterface.bulkDelete('People', null, {});
         */
    },
};
