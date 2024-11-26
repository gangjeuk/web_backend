import { DataTypes, Model } from "sequelize";
export class studentwithcurrentschool extends Model {
    user_id;
    name_glb;
    nationality;
    age;
    student_phone_number;
    emergency_contact;
    gender;
    image;
    has_car;
    keyword_list;
    id;
    student_id;
    degree;
    start_date;
    end_date;
    status;
    faculty;
    school_email;
    is_attending;
    school_id;
    school_name;
    school_name_glb;
    country_code;
    address;
    coordinate;
    hompage_url;
    email_domain;
    phone_number;
    static initModel(sequelize) {
        return studentwithcurrentschool.init({
            user_id: {
                type: DataTypes.BLOB,
                allowNull: false,
            },
            name_glb: {
                type: DataTypes.JSON,
                allowNull: false,
            },
            nationality: {
                type: DataTypes.STRING(4),
                allowNull: false,
            },
            age: {
                type: DataTypes.STRING(4),
                allowNull: false,
            },
            student_phone_number: {
                type: DataTypes.STRING(32),
                allowNull: false,
            },
            emergency_contact: {
                type: DataTypes.STRING(32),
                allowNull: false,
            },
            gender: {
                type: DataTypes.STRING(8),
                allowNull: false,
            },
            image: {
                type: DataTypes.STRING(255),
                allowNull: true,
            },
            has_car: {
                type: DataTypes.BLOB,
                allowNull: true,
            },
            keyword_list: {
                type: DataTypes.JSON,
                allowNull: true,
            },
            id: {
                type: DataTypes.INTEGER,
                allowNull: false,
                defaultValue: 0,
                primaryKey: true,
            },
            student_id: {
                type: DataTypes.INTEGER,
                allowNull: false,
            },
            degree: {
                type: DataTypes.STRING(255),
                allowNull: false,
            },
            start_date: {
                type: DataTypes.DATEONLY,
                allowNull: false,
            },
            end_date: {
                type: DataTypes.DATEONLY,
                allowNull: false,
            },
            status: {
                type: DataTypes.STRING(255),
                allowNull: false,
            },
            faculty: {
                type: DataTypes.STRING(255),
                allowNull: false,
            },
            school_email: {
                type: DataTypes.STRING(255),
                allowNull: true,
            },
            is_attending: {
                type: DataTypes.TINYINT,
                allowNull: true,
                defaultValue: 0,
                comment: "Whether a student is attending a school now or not.\n\nIf a Student is connected to multiple AcademicHistory, only one is_attending should be set true.\n\nUser can have multiple AcademicHistory, but s/he must be attending only one school.\n\n",
            },
            school_id: {
                type: DataTypes.INTEGER,
                allowNull: false,
            },
            school_name: {
                type: DataTypes.STRING(255),
                allowNull: false,
            },
            school_name_glb: {
                type: DataTypes.JSON,
                allowNull: false,
            },
            country_code: {
                type: DataTypes.STRING(4),
                allowNull: false,
            },
            address: {
                type: DataTypes.STRING(255),
                allowNull: false,
            },
            coordinate: {
                type: DataTypes.GEOMETRY("POINT"),
                allowNull: false,
                comment: "School can have multiple campus\n",
            },
            hompage_url: {
                type: DataTypes.STRING(255),
                allowNull: true,
            },
            email_domain: {
                type: DataTypes.STRING(45),
                allowNull: true,
            },
            phone_number: {
                type: DataTypes.STRING(45),
                allowNull: true,
            },
        }, {
            sequelize,
            tableName: "studentwithcurrentschool",
            timestamps: false,
        });
    }
}
