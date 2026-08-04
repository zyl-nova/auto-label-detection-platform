/*
 Navicat Premium Data Transfer

 Source Server         : postgresql
 Source Server Type    : PostgreSQL
 Source Server Version : 160002 (160002)
 Source Host           : 192.168.254.128:5432
 Source Catalog        : postgres
 Source Schema         : public

 Target Server Type    : PostgreSQL
 Target Server Version : 160002 (160002)
 File Encoding         : 65001

Date: 17/11/2024 22:20:20
*/

-- ----------------------------
-- Function structure for snow_next_id
-- ----------------------------
CREATE OR REPLACE FUNCTION "public"."snow_next_id"(OUT "result" int8)
  RETURNS "pg_catalog"."int8" AS $BODY$
DECLARE
   our_epoch bigint := 1314220021721;
   seq_id bigint;
   now_millis bigint;
   shard_id int := 5;
BEGIN
   seq_id := nextval('table_id_seq') % 1024;
   SELECT FLOOR(EXTRACT(EPOCH FROM clock_timestamp()) * 1000) INTO now_millis;
   result := (now_millis - our_epoch) << 23;
   result := result | (shard_id << 10);
   result := result | (seq_id);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- ----------------------------
-- Sequence structure for conf_model_center_tree_list_sort_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."conf_model_center_tree_list_sort_seq";
CREATE SEQUENCE "public"."conf_model_center_tree_list_sort_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for details_files_manager_files_sort_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."details_files_manager_files_sort_seq";
CREATE SEQUENCE "public"."details_files_manager_files_sort_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for info_files_manager_info_sort_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."info_files_manager_info_sort_seq";
CREATE SEQUENCE "public"."info_files_manager_info_sort_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for info_label_task_sort_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."info_label_task_sort_seq";
CREATE SEQUENCE "public"."info_label_task_sort_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for info_model_center_model_base_info_sort_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."info_model_center_model_base_info_sort_seq";
CREATE SEQUENCE "public"."info_model_center_model_base_info_sort_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for info_task_center_train_info_sort_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."info_task_center_train_info_sort_seq";
CREATE SEQUENCE "public"."info_task_center_train_info_sort_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_menu_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_menu_id_seq";
CREATE SEQUENCE "public"."sys_menu_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_role_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_role_id_seq";
CREATE SEQUENCE "public"."sys_role_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_user_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_user_id_seq";
CREATE SEQUENCE "public"."sys_user_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sys_user_role_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sys_user_role_id_seq";
CREATE SEQUENCE "public"."sys_user_role_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for table_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."table_id_seq";
CREATE SEQUENCE "public"."table_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 99999999
START 1
CACHE 1
CYCLE ;

-- ----------------------------
-- Table structure for app_business_state
-- ----------------------------
DROP TABLE IF EXISTS "public"."app_business_state";
CREATE TABLE "public"."app_business_state" (
  "state_key" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
  "state_data" jsonb,
  "update_time" timestamp(6) without time zone
);
COMMENT ON COLUMN "public"."app_business_state"."state_key" IS '业务状态key';
COMMENT ON COLUMN "public"."app_business_state"."state_data" IS '前端业务状态JSON';
COMMENT ON COLUMN "public"."app_business_state"."update_time" IS '更新时间';
COMMENT ON TABLE "public"."app_business_state" IS '应用业务状态缓存';

-- ----------------------------
-- Table structure for clientdetails
-- ----------------------------
DROP TABLE IF EXISTS "public"."clientdetails";
CREATE TABLE "public"."clientdetails" (
  "appid" varchar(48) COLLATE "pg_catalog"."default" NOT NULL,
  "resourceids" varchar(256) COLLATE "pg_catalog"."default",
  "appsecret" varchar(256) COLLATE "pg_catalog"."default",
  "scope" varchar(256) COLLATE "pg_catalog"."default",
  "granttypes" varchar(256) COLLATE "pg_catalog"."default",
  "redirecturl" varchar(256) COLLATE "pg_catalog"."default",
  "authorities" varchar(256) COLLATE "pg_catalog"."default",
  "access_token_validity" int4,
  "refresh_token_validity" int4,
  "additionalinformation" varchar(4096) COLLATE "pg_catalog"."default",
  "autoapprovescopes" varchar(256) COLLATE "pg_catalog"."default"
)
;

-- ----------------------------
-- Records of clientdetails
-- ----------------------------

-- ----------------------------
-- Table structure for conf_proj_tree_list
-- ----------------------------
DROP TABLE IF EXISTS "public"."conf_proj_tree_list";
CREATE TABLE "public"."conf_proj_tree_list" (
  "id" int8 NOT NULL DEFAULT snow_next_id(),
  "code" varchar COLLATE "pg_catalog"."default",
  "p_code" varchar COLLATE "pg_catalog"."default",
  "p_id" int8,
  "name" varchar COLLATE "pg_catalog"."default",
  "sort" int4 DEFAULT nextval('conf_model_center_tree_list_sort_seq'::regclass),
  "create_time" timestamp(6),
  "update_time" timestamp(6),
  "logical_delete" int4
)
;
COMMENT ON COLUMN "public"."conf_proj_tree_list"."code" IS '英文名称';
COMMENT ON COLUMN "public"."conf_proj_tree_list"."p_code" IS '父级英文名称';
COMMENT ON COLUMN "public"."conf_proj_tree_list"."p_id" IS '父级id';
COMMENT ON COLUMN "public"."conf_proj_tree_list"."name" IS '中文名称';
COMMENT ON COLUMN "public"."conf_proj_tree_list"."sort" IS '列表显示排序';
COMMENT ON COLUMN "public"."conf_proj_tree_list"."logical_delete" IS '逻辑删除 1:删除 0:未删除';
COMMENT ON TABLE "public"."conf_proj_tree_list" IS '项目列表';

-- ----------------------------
-- Records of conf_proj_tree_list
-- ----------------------------
INSERT INTO "public"."conf_proj_tree_list" VALUES (1, 'proj_1', NULL, NULL, '项目1', 0, NULL, NULL, 0);
INSERT INTO "public"."conf_proj_tree_list" VALUES (3, 'proj_2', NULL, NULL, '项目2', 2, NULL, NULL, 0);
INSERT INTO "public"."conf_proj_tree_list" VALUES (2, 'prevent_foolish', 'proj_1', 1, '防呆1-1', 1, NULL, NULL, 0);
INSERT INTO "public"."conf_proj_tree_list" VALUES (4, 'prevent_foolish', 'proj_2', 3, '防呆2-1', 4, NULL, NULL, 0);

-- ----------------------------
-- Table structure for info_files_manager_info
-- ----------------------------
DROP TABLE IF EXISTS "public"."info_files_manager_info";
CREATE TABLE "public"."info_files_manager_info" (
  "id" int8 NOT NULL,
  "code" varchar COLLATE "pg_catalog"."default",
  "e_name" varchar COLLATE "pg_catalog"."default",
  "c_name" varchar COLLATE "pg_catalog"."default",
  "proj_id" int8,
  "sort" int4 DEFAULT nextval('info_files_manager_info_sort_seq'::regclass),
  "original_file_type" int4,
  "create_time" timestamp(6),
  "update_time" timestamp(6),
  "logical_delete" int4,
  "des" varchar COLLATE "pg_catalog"."default",
  "status" int4,
  "original_file_store_url" varchar(255) COLLATE "pg_catalog"."default",
  "disposed_file_store_url" varchar(255) COLLATE "pg_catalog"."default",
  "create_user_id" int8
)
;
COMMENT ON COLUMN "public"."info_files_manager_info"."e_name" IS '英文名称';
COMMENT ON COLUMN "public"."info_files_manager_info"."c_name" IS '中文名称';
COMMENT ON COLUMN "public"."info_files_manager_info"."proj_id" IS 'conf_model_center_tree_list的项目id';
COMMENT ON COLUMN "public"."info_files_manager_info"."sort" IS '列表显示排序';
COMMENT ON COLUMN "public"."info_files_manager_info"."original_file_type" IS '原始文件文件类型 0:图像 1:视频 2:其他';
COMMENT ON COLUMN "public"."info_files_manager_info"."logical_delete" IS '逻辑删除 1:删除 0:未删除';
COMMENT ON COLUMN "public"."info_files_manager_info"."des" IS '描述';
COMMENT ON COLUMN "public"."info_files_manager_info"."status" IS '0：正在上传原始文件 1：正在抽帧 2：完成';
COMMENT ON COLUMN "public"."info_files_manager_info"."original_file_store_url" IS '原始文件存储路径';
COMMENT ON COLUMN "public"."info_files_manager_info"."disposed_file_store_url" IS '处理后的文件存放路径';
COMMENT ON COLUMN "public"."info_files_manager_info"."create_user_id" IS '创建文件用户';
COMMENT ON TABLE "public"."info_files_manager_info" IS '文件管理列表';

-- ----------------------------
-- Records of info_files_manager_info
-- ----------------------------
INSERT INTO "public"."info_files_manager_info" VALUES (504547991944691712, NULL, NULL, NULL, 2, 59, 1, '2024-10-24 14:53:35.328', '2024-10-24 14:53:35.328', 0, '111', 2, 'D:\Java_proj\idtserver\static\originalFiles\19cefd0f-b295-4617-a563-3c4d80b78d0c.mp4', 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o', 48);
INSERT INTO "public"."info_files_manager_info" VALUES (504548090783465472, NULL, NULL, NULL, 4, 60, 1, '2024-10-24 14:53:58.893', '2024-10-24 14:53:58.893', 0, '321', 2, 'D:\Java_proj\idtserver\static\originalFiles\4a74ed9f-0a73-45eb-b104-a59a3078c872.mp4', 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o', 48);
INSERT INTO "public"."info_files_manager_info" VALUES (504549879482155008, NULL, NULL, NULL, 2, 61, 1, '2024-10-24 15:01:05.352', '2024-10-24 15:01:05.352', 0, '1234', 2, 'D:\Java_proj\idtserver\static\originalFiles\8ed3db9e-3667-4cfa-81b3-766d497fa43a.mp4', 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o', 48);
INSERT INTO "public"."info_files_manager_info" VALUES (507439790572961792, NULL, NULL, NULL, 2, 62, 1, '2024-11-01 14:24:33.848', '2024-11-01 14:24:33.848', 0, '', 2, 'D:\Java_proj\idtserver\static\originalFiles\c04739db-4bd4-4bc5-8ddc-537372d208c7.mp4', 'D:\Java_proj\idtserver\static\pics2Train\c04739db-4bd4-4bc5-8ddc-537372d208c7_o', 48);

-- ----------------------------
-- Table structure for info_label_task
-- ----------------------------
DROP TABLE IF EXISTS "public"."info_label_task";
CREATE TABLE "public"."info_label_task" (
  "id" int8 NOT NULL DEFAULT snow_next_id(),
  "proj_id" int8,
  "e_name" varchar(255) COLLATE "pg_catalog"."default",
  "c_name" varchar(255) COLLATE "pg_catalog"."default",
  "dead_line" timestamp(6),
  "status" int4,
  "sort" int4 DEFAULT nextval('info_label_task_sort_seq'::regclass),
  "create_time" timestamp(6),
  "update_time" timestamp(6),
  "logical_delete" int4,
  "desc" varchar(255) COLLATE "pg_catalog"."default",
  "info_files_manager_info_id" int8
)
;
COMMENT ON COLUMN "public"."info_label_task"."proj_id" IS '项目id';
COMMENT ON COLUMN "public"."info_label_task"."dead_line" IS '标注完成期限';
COMMENT ON COLUMN "public"."info_label_task"."status" IS '任务状态 0：待审核 1：已完成 2：审核未通过';
COMMENT ON COLUMN "public"."info_label_task"."sort" IS '显示排序';
COMMENT ON COLUMN "public"."info_label_task"."logical_delete" IS '逻辑删除 1:删除 0:未删除';
COMMENT ON COLUMN "public"."info_label_task"."desc" IS '描述';
COMMENT ON COLUMN "public"."info_label_task"."info_files_manager_info_id" IS '表info_files_manager_info的id';
COMMENT ON TABLE "public"."info_label_task" IS '标注任务';

-- ----------------------------
-- Records of info_label_task
-- ----------------------------

-- ----------------------------
-- Table structure for info_model_center_model_base_info
-- ----------------------------
DROP TABLE IF EXISTS "public"."info_model_center_model_base_info";
CREATE TABLE "public"."info_model_center_model_base_info" (
  "id" int8 NOT NULL DEFAULT snow_next_id(),
  "code" varchar COLLATE "pg_catalog"."default",
  "e_name" varchar COLLATE "pg_catalog"."default",
  "c_name" varchar COLLATE "pg_catalog"."default",
  "proj_id" int8,
  "sort" int4 DEFAULT nextval('info_model_center_model_base_info_sort_seq'::regclass),
  "model_dir_url" varchar COLLATE "pg_catalog"."default",
  "create_time" timestamp(6),
  "update_time" timestamp(6),
  "logical_delete" int4,
  "status" int4,
  "des" varchar COLLATE "pg_catalog"."default"
)
;
COMMENT ON COLUMN "public"."info_model_center_model_base_info"."e_name" IS '英文名称';
COMMENT ON COLUMN "public"."info_model_center_model_base_info"."c_name" IS '中文名称';
COMMENT ON COLUMN "public"."info_model_center_model_base_info"."proj_id" IS 'conf_model_center_tree_list的项目id';
COMMENT ON COLUMN "public"."info_model_center_model_base_info"."sort" IS '列表显示排序';
COMMENT ON COLUMN "public"."info_model_center_model_base_info"."model_dir_url" IS '模型存储文件夹路径';
COMMENT ON COLUMN "public"."info_model_center_model_base_info"."logical_delete" IS '逻辑删除 1:删除 0:未删除';
COMMENT ON COLUMN "public"."info_model_center_model_base_info"."status" IS '当前模型训练情况 0:正在训练 1:训练失败 2:训练成功';
COMMENT ON COLUMN "public"."info_model_center_model_base_info"."des" IS '描述';
COMMENT ON TABLE "public"."info_model_center_model_base_info" IS '模型中心模型列表';

-- ----------------------------
-- Records of info_model_center_model_base_info
-- ----------------------------
INSERT INTO "public"."info_model_center_model_base_info" VALUES (3394381393126495302, NULL, NULL, NULL, NULL, 27, 'D:\Java_proj\idtserver\static\modelFiles/a52f8191-bb4b-40a6-b66b-2478e69c27f8', '2024-06-20 13:36:53.851', '2024-06-20 13:36:53.851', 0, 0, NULL);
INSERT INTO "public"."info_model_center_model_base_info" VALUES (3394390533957751880, NULL, '111', NULL, 2, 28, 'D:\Java_proj\idtserver\static\modelFiles/7d9b5033-64a3-4b8c-9465-be47791ebf00_1', '2024-06-20 13:55:03.48', '2024-06-20 13:55:03.48', 0, 2, '122');
INSERT INTO "public"."info_model_center_model_base_info" VALUES (3394416325001483337, NULL, 'Hello', NULL, 4, 29, 'D:\Java_proj\idtserver\static\modelFiles/e5d7e807-3713-46ea-82df-c9be5eb3cfbd_1', '2024-06-20 14:46:17.888', '2024-06-20 14:46:17.888', 0, 2, '123');
INSERT INTO "public"."info_model_center_model_base_info" VALUES (3394430001360147530, NULL, NULL, NULL, NULL, 30, 'D:\Java_proj\idtserver\static\modelFiles/c19fca56-a75e-4399-b158-1602531dfb23', '2024-06-20 15:13:28.175', '2024-06-20 15:13:28.175', 0, 0, NULL);
INSERT INTO "public"."info_model_center_model_base_info" VALUES (3394452291091174476, NULL, NULL, NULL, NULL, 31, 'D:\Java_proj\idtserver\static\modelFiles/78625e73-7585-4cf7-95b5-80db68298a50', '2024-06-20 15:57:45.201', '2024-06-20 15:57:45.201', 0, 0, NULL);
INSERT INTO "public"."info_model_center_model_base_info" VALUES (3402259288385655888, NULL, 'H444', NULL, 2, 34, 'D:\Java_proj\idtserver\static\modelFiles/50b4e274-e5df-40eb-bc1d-9bb7a2922a8f_1', '2024-07-01 10:28:54.31', '2024-07-01 10:28:54.31', 0, 1, '123');
INSERT INTO "public"."info_model_center_model_base_info" VALUES (3402255722061239375, NULL, 'H333', NULL, 2, 33, 'D:\Java_proj\idtserver\static\modelFiles/e6c62308-1470-40dd-b85a-1ea01cb863b7_1', '2024-07-01 10:21:49.172', '2024-07-01 10:21:49.172', 0, 1, '123');
INSERT INTO "public"."info_model_center_model_base_info" VALUES (3402254721719735374, NULL, 'H22', NULL, 2, 32, 'D:\Java_proj\idtserver\static\modelFiles/b7258cc3-4ad6-4abe-8f41-ab8530d9edbf_1', '2024-07-01 10:19:49.941', '2024-07-01 10:19:49.941', 0, 1, '123');
INSERT INTO "public"."info_model_center_model_base_info" VALUES (3402260509028783185, NULL, NULL, NULL, NULL, 35, 'D:\Java_proj\idtserver\static\modelFiles/301df39a-7660-4fcc-b244-177217d3c378', '2024-07-01 10:31:19.841', '2024-07-01 10:31:19.841', 0, 1, NULL);

-- ----------------------------
-- Table structure for info_sample_center
-- ----------------------------
DROP TABLE IF EXISTS "public"."info_sample_center";
CREATE TABLE "public"."info_sample_center" (
  "id" int8 NOT NULL DEFAULT snow_next_id(),
  "e_name" varchar(255) COLLATE "pg_catalog"."default",
  "c_name" varchar(255) COLLATE "pg_catalog"."default",
  "proj_id" int8,
  "import_mode" int4,
  "desc" varchar(255) COLLATE "pg_catalog"."default",
  "sample_type" int4,
  "label_mode" int4
)
;
COMMENT ON COLUMN "public"."info_sample_center"."proj_id" IS 'conf_model_center_tree_list的项目id';
COMMENT ON COLUMN "public"."info_sample_center"."import_mode" IS '导入方式 0：上传';
COMMENT ON COLUMN "public"."info_sample_center"."desc" IS '描述';
COMMENT ON COLUMN "public"."info_sample_center"."sample_type" IS '样本类型 0：图像 1：结构化数据';
COMMENT ON COLUMN "public"."info_sample_center"."label_mode" IS '标注格式 0：json 1：xml';
COMMENT ON TABLE "public"."info_sample_center" IS '样本中心';

-- ----------------------------
-- Records of info_sample_center
-- ----------------------------

-- ----------------------------
-- Table structure for info_task_center_train_info
-- ----------------------------
DROP TABLE IF EXISTS "public"."info_task_center_train_info";
CREATE TABLE "public"."info_task_center_train_info" (
  "id" int8 NOT NULL DEFAULT snow_next_id(),
  "task_name" varchar COLLATE "pg_catalog"."default",
  "proj_id" int8,
  "des" varchar COLLATE "pg_catalog"."default",
  "pre_train_model_id" int8,
  "sample_url" varchar COLLATE "pg_catalog"."default",
  "model_output_url" varchar COLLATE "pg_catalog"."default",
  "learning_rate" float8,
  "epoch" int8,
  "batch_size" int4,
  "test_files_url" varchar COLLATE "pg_catalog"."default",
  "sort" int4 DEFAULT nextval('info_task_center_train_info_sort_seq'::regclass),
  "create_time" timestamp(6),
  "update_time" timestamp(6),
  "logical_delete" int4,
  "model_id" int8
)
;
COMMENT ON COLUMN "public"."info_task_center_train_info"."task_name" IS '任务名称';
COMMENT ON COLUMN "public"."info_task_center_train_info"."proj_id" IS '项目id';
COMMENT ON COLUMN "public"."info_task_center_train_info"."des" IS '描述';
COMMENT ON COLUMN "public"."info_task_center_train_info"."pre_train_model_id" IS '预训练模型id';
COMMENT ON COLUMN "public"."info_task_center_train_info"."sample_url" IS '样本路径';
COMMENT ON COLUMN "public"."info_task_center_train_info"."model_output_url" IS '模型存储路径';
COMMENT ON COLUMN "public"."info_task_center_train_info"."learning_rate" IS '学习率';
COMMENT ON COLUMN "public"."info_task_center_train_info"."epoch" IS 'epoch';
COMMENT ON COLUMN "public"."info_task_center_train_info"."batch_size" IS '批量大小';
COMMENT ON COLUMN "public"."info_task_center_train_info"."test_files_url" IS '测试文件';
COMMENT ON COLUMN "public"."info_task_center_train_info"."sort" IS '排序';
COMMENT ON COLUMN "public"."info_task_center_train_info"."logical_delete" IS '逻辑删除 1:删除 0:未删除';
COMMENT ON COLUMN "public"."info_task_center_train_info"."model_id" IS '模型id';
COMMENT ON TABLE "public"."info_task_center_train_info" IS '任务中心模型训练';

-- ----------------------------
-- Records of info_task_center_train_info
-- ----------------------------
INSERT INTO "public"."info_task_center_train_info" VALUES (3394381393160049735, 'Hello', 2, '123', 1, 'D:\Java_proj\idtserver\static\pics2Train\cb41ba40-21c2-4c45-be26-9223b8322138', '', 0.2, 100, 20, 'test1', 1, '2024-06-20 13:36:53.859', '2024-06-20 13:36:53.859', 0, 3394381393126495302);
INSERT INTO "public"."info_task_center_train_info" VALUES (3394430001385313355, 'H222', 2, '123', 1, 'D:\Java_proj\idtserver\static\pics2Train\4c184d47-3e5e-442e-b808-09df9a754de8', '', 0.2, 100, 20, 'test1', 2, '2024-06-20 15:13:28.179', '2024-06-20 15:13:28.179', 0, 3394430001360147530);
INSERT INTO "public"."info_task_center_train_info" VALUES (3394452291133117517, 'H33', 2, '123', 1, 'D:\Java_proj\idtserver\static\pics2Train\ad077dae-df84-4ed0-971b-d4d31f0c75b7', '', 0.2, 100, 20, 'test2', 3, '2024-06-20 15:57:45.208', '2024-06-20 15:57:45.208', 0, 3394452291091174476);
INSERT INTO "public"."info_task_center_train_info" VALUES (3402260509037171794, 'H333', 2, '123', 1, 'D:\Java_proj\idtserver\static\pics2Train\88823ad5-78d5-45c0-bf37-2f2ce9edebfd', '', 0.2, 100, 20, 'test2', 4, '2024-07-01 10:31:19.843', '2024-07-01 10:31:19.843', 0, 3402260509028783185);

-- ----------------------------
-- Table structure for map_label_task_pics_to_user
-- ----------------------------
DROP TABLE IF EXISTS "public"."map_label_task_pics_to_user";
CREATE TABLE "public"."map_label_task_pics_to_user" (
  "id" int8 NOT NULL DEFAULT snow_next_id(),
  "info_files_manager_info_id" int8,
  "info_label_task_id" int8,
  "label_data" jsonb,
  "label_list" jsonb,
  "user_id" int4,
  "review_status" int4,
  "create_time" timestamp(6),
  "update_time" timestamp(6),
  "logical_delete" int4,
  "pic_store_url" varchar(255) COLLATE "pg_catalog"."default"
)
;
COMMENT ON COLUMN "public"."map_label_task_pics_to_user"."info_files_manager_info_id" IS 'info_files_manager_info的ID';
COMMENT ON COLUMN "public"."map_label_task_pics_to_user"."info_label_task_id" IS '表info_label_task_id的id';
COMMENT ON COLUMN "public"."map_label_task_pics_to_user"."label_data" IS '标注数据';
COMMENT ON COLUMN "public"."map_label_task_pics_to_user"."label_list" IS '标注的标签列表';
COMMENT ON COLUMN "public"."map_label_task_pics_to_user"."user_id" IS '映射表 标注任务和对应人员表的id';
COMMENT ON COLUMN "public"."map_label_task_pics_to_user"."review_status" IS '审核状态 0：未审核 1：审核通过 2：审核未通过';
COMMENT ON COLUMN "public"."map_label_task_pics_to_user"."logical_delete" IS '逻辑删除 1:删除 0:未删除';
COMMENT ON COLUMN "public"."map_label_task_pics_to_user"."pic_store_url" IS '图片具体路径';
COMMENT ON TABLE "public"."map_label_task_pics_to_user" IS '标注任务的具体图片对应到用户，并且记录标注图片的任务状态';

-- ----------------------------
-- Records of map_label_task_pics_to_user
-- ----------------------------
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668007, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00000.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668008, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00002.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668009, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00001.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668010, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00003.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668011, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00004.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668012, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00005.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668013, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00006.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668014, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00007.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668015, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00008.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668016, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00009.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668017, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00010.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668018, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00011.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668019, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00012.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668020, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00013.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668021, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00014.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668022, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00015.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668023, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00016.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668024, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00017.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668025, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00018.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668026, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00019.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668027, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00020.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668028, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00021.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668029, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00022.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668030, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00023.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668031, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00024.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668032, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00025.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668033, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00026.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668034, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00027.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668035, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00028.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668036, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00029.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668037, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00030.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668038, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00031.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668039, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00032.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668040, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00033.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668041, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00034.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668042, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00035.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668043, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00036.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668044, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00037.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668045, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00038.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668046, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00039.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668047, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00040.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668048, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00041.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668049, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00042.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668050, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00043.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668051, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00044.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668052, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00045.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668053, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00046.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668054, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00047.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668055, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00048.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668056, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00049.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668057, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00050.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668058, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00051.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668059, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00052.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668060, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00053.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668061, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00054.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668062, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00055.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668063, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00056.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668064, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00057.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668065, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00058.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668066, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00059.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668067, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00060.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668068, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00061.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668069, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00062.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668070, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00063.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668071, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00064.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668072, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00065.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668073, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00066.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668074, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00067.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668075, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00068.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668076, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00069.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668077, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00070.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668078, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00071.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668079, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00072.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668080, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00073.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668081, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00074.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668082, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00075.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668083, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00076.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668084, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00077.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668085, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00078.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668086, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00079.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668087, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00080.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668088, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00081.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668089, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00082.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668090, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00083.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668091, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00084.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668092, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00085.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668093, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00086.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485741812268668094, 504547991944691712, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\19cefd0f-b295-4617-a563-3c4d80b78d0c_o/frame_00087.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840831, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00001.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840832, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00000.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840833, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00002.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840834, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00003.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840835, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00004.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840836, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00005.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840837, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00006.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840838, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00007.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840839, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00008.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840840, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00009.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840841, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00010.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840842, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00011.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840843, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00012.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840844, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00013.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840845, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00014.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840846, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00015.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840847, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00016.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840848, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00017.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840849, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00018.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840850, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00019.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840851, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00020.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840852, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00021.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840853, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00022.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840854, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00023.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840855, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00024.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840856, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00025.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840857, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00026.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840858, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00027.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840859, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00028.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840860, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00029.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840861, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00030.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840862, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00031.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840863, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00032.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840864, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00033.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840865, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00034.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840866, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00035.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840867, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00036.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840868, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00037.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840869, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00038.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840870, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00039.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840871, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00040.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840872, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00041.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840873, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00042.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840874, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00043.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840875, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00044.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840876, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00045.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840877, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00046.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840878, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00047.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840879, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00048.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840880, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00049.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840881, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00050.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840882, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00051.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840883, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00052.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840884, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00053.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840885, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00054.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840886, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00055.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840887, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00056.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840888, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00057.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840889, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00058.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840890, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00059.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840891, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00060.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840892, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00061.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840893, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00062.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840894, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00063.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840895, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00064.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840896, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00065.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840897, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00066.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840898, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00067.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840899, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00068.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840900, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00069.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840901, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00070.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840902, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00071.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840903, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00072.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840904, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00073.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840905, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00074.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840906, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00075.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840907, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00076.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840908, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00077.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840909, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00078.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840910, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00079.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840911, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00080.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840912, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00081.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840913, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00082.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840914, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00083.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840915, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00084.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840916, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00085.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840917, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00086.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485742007865840918, 504548090783465472, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\4a74ed9f-0a73-45eb-b104-a59a3078c872_o/frame_00087.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583988151575, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00001.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540184, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00000.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540185, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00002.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540186, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00003.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540187, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00004.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540188, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00005.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540189, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00006.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540190, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00007.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540191, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00008.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540192, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00009.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540193, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00010.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540194, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00011.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540195, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00012.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540196, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00013.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540197, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00014.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540198, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00015.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540199, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00016.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540200, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00017.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540201, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00018.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540202, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00019.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540203, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00020.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540204, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00021.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540205, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00022.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540206, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00023.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540207, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00024.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540208, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00025.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540209, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00026.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540210, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00027.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540211, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00028.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540212, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00029.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540213, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00030.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540214, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00031.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540215, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00032.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540216, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00033.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540217, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00034.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540218, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00035.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540219, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00036.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540220, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00037.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540221, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00038.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540222, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00039.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540223, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00040.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540224, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00041.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540225, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00042.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540226, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00043.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540227, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00044.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540228, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00045.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540229, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00046.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540230, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00047.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540231, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00048.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540232, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00049.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540233, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00050.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540234, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00051.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540235, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00052.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540236, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00053.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540237, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00054.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540238, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00055.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540239, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00056.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540240, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00057.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540241, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00058.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540242, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00059.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540243, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00060.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540244, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00061.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540245, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00062.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540246, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00063.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540247, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00064.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540248, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00065.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540249, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00066.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540250, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00067.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540251, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00068.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540252, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00069.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540253, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00070.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540254, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00071.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540255, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00072.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540256, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00073.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540257, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00074.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540258, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00075.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540259, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00076.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540260, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00077.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540261, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00078.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540262, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00079.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540263, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00080.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540264, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00081.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540265, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00082.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540266, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00083.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540267, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00084.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540268, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00085.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540269, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00086.png');
INSERT INTO "public"."map_label_task_pics_to_user" VALUES (3485745583996540270, 504549879482155008, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'D:\Java_proj\idtserver\static\pics2Train\8ed3db9e-3667-4cfa-81b3-766d497fa43a_o/frame_00087.png');

-- ----------------------------
-- Table structure for map_label_task_to_user
-- ----------------------------
DROP TABLE IF EXISTS "public"."map_label_task_to_user";
CREATE TABLE "public"."map_label_task_to_user" (
  "id" int8 NOT NULL DEFAULT snow_next_id(),
  "label_task_id" int8,
  "label_user_id" int4,
  "reviewer_id" int4,
  "create_time" timestamp(6),
  "update_time" timestamp(6)
)
;
COMMENT ON COLUMN "public"."map_label_task_to_user"."label_task_id" IS '标注任务的id';
COMMENT ON COLUMN "public"."map_label_task_to_user"."label_user_id" IS '标注人id';
COMMENT ON COLUMN "public"."map_label_task_to_user"."reviewer_id" IS '审核人id';
COMMENT ON TABLE "public"."map_label_task_to_user" IS '映射表：标注任务和标注用户、审核用户';

-- ----------------------------
-- Records of map_label_task_to_user
-- ----------------------------

-- ----------------------------
-- Table structure for oauth_access_token
-- ----------------------------
DROP TABLE IF EXISTS "public"."oauth_access_token";
CREATE TABLE "public"."oauth_access_token" (
  "token_id" varchar(256) COLLATE "pg_catalog"."default",
  "token" bytea,
  "authentication_id" varchar(48) COLLATE "pg_catalog"."default" NOT NULL,
  "user_name" varchar(256) COLLATE "pg_catalog"."default",
  "client_id" varchar(256) COLLATE "pg_catalog"."default",
  "authentication" bytea,
  "refresh_token" varchar(256) COLLATE "pg_catalog"."default"
)
;

-- ----------------------------
-- Records of oauth_access_token
-- ----------------------------

-- ----------------------------
-- Table structure for oauth_approvals
-- ----------------------------
DROP TABLE IF EXISTS "public"."oauth_approvals";
CREATE TABLE "public"."oauth_approvals" (
  "userid" varchar(256) COLLATE "pg_catalog"."default",
  "clientid" varchar(256) COLLATE "pg_catalog"."default",
  "scope" varchar(256) COLLATE "pg_catalog"."default",
  "status" varchar(10) COLLATE "pg_catalog"."default",
  "expiresat" timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "lastmodifiedat" timestamp(6) NOT NULL DEFAULT '0001-01-01 00:00:00'::timestamp without time zone
)
;

-- ----------------------------
-- Records of oauth_approvals
-- ----------------------------

-- ----------------------------
-- Table structure for oauth_client_details
-- ----------------------------
DROP TABLE IF EXISTS "public"."oauth_client_details";
CREATE TABLE "public"."oauth_client_details" (
  "client_id" varchar(48) COLLATE "pg_catalog"."default" NOT NULL,
  "resource_ids" varchar(256) COLLATE "pg_catalog"."default",
  "client_secret" varchar(256) COLLATE "pg_catalog"."default",
  "scope" varchar(256) COLLATE "pg_catalog"."default",
  "authorized_grant_types" varchar(256) COLLATE "pg_catalog"."default",
  "web_server_redirect_uri" varchar(256) COLLATE "pg_catalog"."default",
  "authorities" varchar(256) COLLATE "pg_catalog"."default",
  "access_token_validity" int4,
  "refresh_token_validity" int4,
  "additional_information" varchar(4096) COLLATE "pg_catalog"."default",
  "autoapprove" varchar(256) COLLATE "pg_catalog"."default"
)
;

-- ----------------------------
-- Records of oauth_client_details
-- ----------------------------
INSERT INTO "public"."oauth_client_details" VALUES ('app', NULL, 'app', 'app', 'password,refresh_token', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "public"."oauth_client_details" VALUES ('webApp', NULL, '$2a$10$cKRbR9IJktfmKmf/wShyo.5.J8IxO/7YVn8twuWFtvPgruAF8gtKq', 'app', 'authorization_code,password,refresh_token,client_credentials', NULL, NULL, NULL, NULL, NULL, NULL);

-- ----------------------------
-- Table structure for oauth_client_token
-- ----------------------------
DROP TABLE IF EXISTS "public"."oauth_client_token";
CREATE TABLE "public"."oauth_client_token" (
  "token_id" varchar(256) COLLATE "pg_catalog"."default",
  "token" bytea,
  "authentication_id" varchar(48) COLLATE "pg_catalog"."default" NOT NULL,
  "user_name" varchar(256) COLLATE "pg_catalog"."default",
  "client_id" varchar(256) COLLATE "pg_catalog"."default"
)
;

-- ----------------------------
-- Records of oauth_client_token
-- ----------------------------

-- ----------------------------
-- Table structure for oauth_code
-- ----------------------------
DROP TABLE IF EXISTS "public"."oauth_code";
CREATE TABLE "public"."oauth_code" (
  "code" varchar(256) COLLATE "pg_catalog"."default",
  "authentication" bytea
)
;

-- ----------------------------
-- Records of oauth_code
-- ----------------------------

-- ----------------------------
-- Table structure for oauth_refresh_token
-- ----------------------------
DROP TABLE IF EXISTS "public"."oauth_refresh_token";
CREATE TABLE "public"."oauth_refresh_token" (
  "token_id" varchar(256) COLLATE "pg_catalog"."default",
  "token" bytea,
  "authentication" bytea
)
;

-- ----------------------------
-- Records of oauth_refresh_token
-- ----------------------------
INSERT INTO "public"."oauth_refresh_token" VALUES ('b96e057b4e1c4920428e833db48d4c15', E'0xACED00057372004C6F72672E737072696E676672616D65776F726B2E73656375726974792E6F61757468322E636F6D6D6F6E2E44656661756C744578706972696E674F417574683252656672657368546F6B656E2FDF47639DD0C9B70200014C000A65787069726174696F6E7400104C6A6176612F7574696C2F446174653B787200446F72672E737072696E676672616D65776F726B2E73656375726974792E6F61757468322E636F6D6D6F6E2E44656661756C744F417574683252656672657368546F6B656E73E10E0A6354D45E0200014C000576616C75657400124C6A6176612F6C616E672F537472696E673B787074002462303132643438372D613930382D343361662D613865662D3533633533393963386264367372000E6A6176612E7574696C2E44617465686A81014B59741903000078707708000001613B74C98E78, 0xACED0005737200416F72672E737072696E676672616D65776F726B2E73656375726974792E6F61757468322E70726F76696465722E4F417574683241757468656E7469636174696F6EBD400B02166252130200024C000D73746F7265645265717565737474003C4C6F72672F737072696E676672616D65776F726B2F73656375726974792F6F61757468322F70726F76696465722F4F4175746832526571756573743B4C00127573657241757468656E7469636174696F6E7400324C6F72672F737072696E676672616D65776F726B2F73656375726974792F636F72652F41757468656E7469636174696F6E3B787200476F72672E737072696E676672616D65776F726B2E73656375726974792E61757468656E7469636174696F6E2E416273747261637441757468656E7469636174696F6E546F6B656ED3AA287E6E47640E0200035A000D61757468656E746963617465644C000B617574686F7269746965737400164C6A6176612F7574696C2F436F6C6C656374696F6E3B4C000764657461696C737400124C6A6176612F6C616E672F4F626A6563743B787000737200266A6176612E7574696C2E436F6C6C656374696F6E7324556E6D6F6469666961626C654C697374FC0F2531B5EC8E100200014C00046C6973747400104C6A6176612F7574696C2F4C6973743B7872002C6A6176612E7574696C2E436F6C6C656374696F6E7324556E6D6F6469666961626C65436F6C6C656374696F6E19420080CB5EF71E0200014C00016371007E00047870737200136A6176612E7574696C2E41727261794C6973747881D21D99C7619D03000149000473697A65787000000009770400000009737200426F72672E737072696E676672616D65776F726B2E73656375726974792E636F72652E617574686F726974792E53696D706C654772616E746564417574686F7269747900000000000001A40200014C0004726F6C657400124C6A6176612F6C616E672F537472696E673B787074000A524F4C455F61646D696E7371007E000D740006617069646F637371007E000D74000C64617461626173652F6C6F677371007E000D74000673797374656D7371007E000D740008757365722F6164647371007E000D74000B757365722F64656C6574657371007E000D740009757365722F656469747371007E000D740009757365722F766965777371007E000D740008757365724C6973747871007E000C707372003A6F72672E737072696E676672616D65776F726B2E73656375726974792E6F61757468322E70726F76696465722E4F41757468325265717565737400000000000000010200075A0008617070726F7665644C000B617574686F72697469657371007E00044C000A657874656E73696F6E7374000F4C6A6176612F7574696C2F4D61703B4C000B726564697265637455726971007E000E4C00077265667265736874003B4C6F72672F737072696E676672616D65776F726B2F73656375726974792F6F61757468322F70726F76696465722F546F6B656E526571756573743B4C000B7265736F7572636549647374000F4C6A6176612F7574696C2F5365743B4C000D726573706F6E7365547970657371007E0024787200386F72672E737072696E676672616D65776F726B2E73656375726974792E6F61757468322E70726F76696465722E426173655265717565737436287A3EA37169BD0200034C0008636C69656E74496471007E000E4C001172657175657374506172616D657465727371007E00224C000573636F706571007E00247870740006776562417070737200256A6176612E7574696C2E436F6C6C656374696F6E7324556E6D6F6469666961626C654D6170F1A5A8FE74F507420200014C00016D71007E00227870737200116A6176612E7574696C2E486173684D61700507DAC1C31660D103000246000A6C6F6164466163746F724900097468726573686F6C6478703F400000000000037708000000040000000274000A6772616E745F7479706574000870617373776F7264740008757365726E616D6574000561646D696E78737200256A6176612E7574696C2E436F6C6C656374696F6E7324556E6D6F6469666961626C65536574801D92D18F9B80550200007871007E0009737200176A6176612E7574696C2E4C696E6B656448617368536574D86CD75A95DD2A1E020000787200116A6176612E7574696C2E48617368536574BA44859596B8B7340300007870770C000000103F4000000000000174000361707078017371007E0033770C000000103F40000000000000787371007E002A3F40000000000000770800000010000000007870707371007E0033770C000000103F40000000000000787371007E0033770C000000103F40000000000000787372004F6F72672E737072696E676672616D65776F726B2E73656375726974792E61757468656E7469636174696F6E2E557365726E616D6550617373776F726441757468656E7469636174696F6E546F6B656E00000000000001A40200024C000B63726564656E7469616C7371007E00054C00097072696E636970616C71007E00057871007E0003017371007E00077371007E000B0000000977040000000971007E000F71007E001171007E001371007E001571007E001771007E001971007E001B71007E001D71007E001F7871007E003D737200176A6176612E7574696C2E4C696E6B6564486173684D617034C04E5C106CC0FB0200015A000B6163636573734F726465727871007E002A3F400000000000067708000000080000000271007E002C71007E002D71007E002E71007E002F780070737200326F72672E737072696E676672616D65776F726B2E73656375726974792E636F72652E7573657264657461696C732E5573657200000000000001A40200075A00116163636F756E744E6F6E457870697265645A00106163636F756E744E6F6E4C6F636B65645A001563726564656E7469616C734E6F6E457870697265645A0007656E61626C65644C000B617574686F72697469657371007E00244C000870617373776F726471007E000E4C0008757365726E616D6571007E000E7870010101017371007E0030737200116A6176612E7574696C2E54726565536574DD98509395ED875B0300007870737200466F72672E737072696E676672616D65776F726B2E73656375726974792E636F72652E7573657264657461696C732E5573657224417574686F72697479436F6D70617261746F7200000000000001A4020000787077040000000971007E000F71007E001171007E001371007E001571007E001771007E001971007E001B71007E001D71007E001F787074000561646D696E', NULL);

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_menu";
CREATE TABLE "public"."sys_menu" (
  "id" int4 NOT NULL DEFAULT nextval('sys_menu_id_seq'::regclass),
  "code" varchar(255) COLLATE "pg_catalog"."default",
  "p_code" varchar(255) COLLATE "pg_catalog"."default",
  "p_id" varchar(255) COLLATE "pg_catalog"."default",
  "name" varchar(255) COLLATE "pg_catalog"."default",
  "url" varchar(255) COLLATE "pg_catalog"."default",
  "is_menu" int4,
  "level" int4,
  "sort" int4,
  "status" int4,
  "icon" varchar(255) COLLATE "pg_catalog"."default",
  "create_time" timestamp(6),
  "update_time" timestamp(6)
)
;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO "public"."sys_menu" VALUES (1, 'order', NULL, NULL, '订单管理', NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "public"."sys_menu" VALUES (2, 'order_list', 'order', '1', '订单列表查询', '/mss-upms/order/list', 2, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "public"."sys_menu" VALUES (3, 'order_detail', 'order', '1', '订单详情', '/userserver/order/detail', 2, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "public"."sys_menu" VALUES (4, 'user_name', NULL, '1', '查询当前登录用户', '/UserServer/user/getUserName', 1, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "public"."sys_menu" VALUES (5, 'upload_file', NULL, NULL, '上传文件', '/AIModuleServer/FileManager/addFile', 1, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "public"."sys_menu" VALUES (6, 'list_file_manager', NULL, NULL, '查看文件管理列表', '/AIModuleServer/FileManager/list', 1, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "public"."sys_menu" VALUES (7, 'delete_file_manager', NULL, NULL, '删除文件管理列表', '/AIModuleServer/FileManager/deleteFile', 1, NULL, NULL, NULL, NULL, NULL, NULL);

-- ----------------------------
-- Table structure for sys_privilege
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_privilege";
CREATE TABLE "public"."sys_privilege" (
  "role_id" int4 NOT NULL,
  "menu_id" int4 NOT NULL,
  "create_time" timestamp(6)
)
;

-- ----------------------------
-- Records of sys_privilege
-- ----------------------------
INSERT INTO "public"."sys_privilege" VALUES (6, 1, NULL);
INSERT INTO "public"."sys_privilege" VALUES (6, 2, NULL);
INSERT INTO "public"."sys_privilege" VALUES (6, 3, NULL);
INSERT INTO "public"."sys_privilege" VALUES (6, 4, NULL);
INSERT INTO "public"."sys_privilege" VALUES (6, 5, NULL);
INSERT INTO "public"."sys_privilege" VALUES (6, 6, NULL);
INSERT INTO "public"."sys_privilege" VALUES (6, 7, NULL);

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_role";
CREATE TABLE "public"."sys_role" (
  "id" int4 NOT NULL DEFAULT nextval('sys_role_id_seq'::regclass),
  "name" varchar(255) COLLATE "pg_catalog"."default",
  "value" varchar(255) COLLATE "pg_catalog"."default",
  "tips" varchar(255) COLLATE "pg_catalog"."default",
  "create_time" timestamp(6),
  "update_time" timestamp(6),
  "status" int4 NOT NULL
)
;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO "public"."sys_role" VALUES (6, '管理员', 'admin', NULL, '2020-10-28 15:07:13', NULL, 1);

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_user";
CREATE TABLE "public"."sys_user" (
  "id" int4 NOT NULL DEFAULT nextval('sys_user_id_seq'::regclass),
  "avatar" varchar(255) COLLATE "pg_catalog"."default",
  "username" varchar(45) COLLATE "pg_catalog"."default",
  "password" varchar(96) COLLATE "pg_catalog"."default",
  "salt" varchar(45) COLLATE "pg_catalog"."default",
  "name" varchar(45) COLLATE "pg_catalog"."default",
  "birthday" timestamp(6),
  "sex" int4,
  "email" varchar(45) COLLATE "pg_catalog"."default",
  "phone" varchar(45) COLLATE "pg_catalog"."default",
  "status" int4,
  "create_time" timestamp(6),
  "update_time" timestamp(6)
)
;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO "public"."sys_user" VALUES (50, NULL, 'test1', '$2a$10$vmp.zWWnX3LFxSs6I00i0eurlHR7ymcfUQ5HtXw71w9QJ.2JUf8Ua', NULL, 'test1', NULL, 1, NULL, NULL, 1, '2020-10-27 16:11:15', NULL);
INSERT INTO "public"."sys_user" VALUES (51, NULL, 'test2', '$2a$10$vmp.zWWnX3LFxSs6I00i0eurlHR7ymcfUQ5HtXw71w9QJ.2JUf8Ua', NULL, 'test2', NULL, 1, NULL, NULL, 1, '2020-10-27 17:09:51', NULL);
INSERT INTO "public"."sys_user" VALUES (48, NULL, 'admin', '$2a$10$vmp.zWWnX3LFxSs6I00i0eurlHR7ymcfUQ5HtXw71w9QJ.2JUf8Ua', NULL, '管理员', NULL, 1, NULL, NULL, 1, '2020-10-27 17:31:41', NULL);

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_user_role";
CREATE TABLE "public"."sys_user_role" (
  "id" int4 NOT NULL DEFAULT nextval('sys_user_role_id_seq'::regclass),
  "user_id" int4,
  "role_id" int4,
  "create_time" timestamp(6),
  "create_by" varchar(255) COLLATE "pg_catalog"."default"
)
;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO "public"."sys_user_role" VALUES (1, 48, 6, NULL, NULL);

-- ----------------------------
-- Function structure for snow_next_id
-- ----------------------------
CREATE OR REPLACE FUNCTION "public"."snow_next_id"(OUT "result" int8)
  RETURNS "pg_catalog"."int8" AS $BODY$
DECLARE
   our_epoch bigint := 1314220021721;
   seq_id bigint;
   now_millis bigint;
   shard_id int := 5;
BEGIN
   seq_id := nextval('table_id_seq') % 1024;
   SELECT FLOOR(EXTRACT(EPOCH FROM clock_timestamp()) * 1000) INTO now_millis;
   result := (now_millis - our_epoch) << 23;
   result := result | (shard_id << 10);
   result := result | (seq_id);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
SELECT setval('"public"."conf_model_center_tree_list_sort_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
SELECT setval('"public"."details_files_manager_files_sort_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
SELECT setval('"public"."info_files_manager_info_sort_seq"', 62, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
SELECT setval('"public"."info_label_task_sort_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
SELECT setval('"public"."info_model_center_model_base_info_sort_seq"', 35, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
SELECT setval('"public"."info_task_center_train_info_sort_seq"', 4, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_menu_id_seq"
OWNED BY "public"."sys_menu"."id";
SELECT setval('"public"."sys_menu_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_role_id_seq"
OWNED BY "public"."sys_role"."id";
SELECT setval('"public"."sys_role_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_user_id_seq"
OWNED BY "public"."sys_user"."id";
SELECT setval('"public"."sys_user_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sys_user_role_id_seq"
OWNED BY "public"."sys_user_role"."id";
SELECT setval('"public"."sys_user_role_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
SELECT setval('"public"."table_id_seq"', 366, true);

-- ----------------------------
-- Primary Key structure for table app_business_state
-- ----------------------------
ALTER TABLE "public"."app_business_state" ADD CONSTRAINT "app_business_state_pkey" PRIMARY KEY ("state_key");

-- ----------------------------
-- Primary Key structure for table clientdetails
-- ----------------------------
ALTER TABLE "public"."clientdetails" ADD CONSTRAINT "clientdetails_pkey" PRIMARY KEY ("appid");

-- ----------------------------
-- Primary Key structure for table conf_proj_tree_list
-- ----------------------------
ALTER TABLE "public"."conf_proj_tree_list" ADD CONSTRAINT "conf_model_center_tree_list_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table info_files_manager_info
-- ----------------------------
ALTER TABLE "public"."info_files_manager_info" ADD CONSTRAINT "info_files_manager_info_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table info_label_task
-- ----------------------------
ALTER TABLE "public"."info_label_task" ADD CONSTRAINT "info_label_task_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table info_model_center_model_base_info
-- ----------------------------
ALTER TABLE "public"."info_model_center_model_base_info" ADD CONSTRAINT "info_model_center_model_base_info_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table info_sample_center
-- ----------------------------
ALTER TABLE "public"."info_sample_center" ADD CONSTRAINT "info_sample_center_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table info_task_center_train_info
-- ----------------------------
ALTER TABLE "public"."info_task_center_train_info" ADD CONSTRAINT "info_task_center_train_info_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table map_label_task_pics_to_user
-- ----------------------------
ALTER TABLE "public"."map_label_task_pics_to_user" ADD CONSTRAINT "map_label_task_pic_to_user_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table map_label_task_to_user
-- ----------------------------
ALTER TABLE "public"."map_label_task_to_user" ADD CONSTRAINT "map_label_task_to_user_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table oauth_access_token
-- ----------------------------
ALTER TABLE "public"."oauth_access_token" ADD CONSTRAINT "oauth_access_token_pkey" PRIMARY KEY ("authentication_id");

-- ----------------------------
-- Primary Key structure for table oauth_client_details
-- ----------------------------
ALTER TABLE "public"."oauth_client_details" ADD CONSTRAINT "oauth_client_details_pkey" PRIMARY KEY ("client_id");

-- ----------------------------
-- Primary Key structure for table oauth_client_token
-- ----------------------------
ALTER TABLE "public"."oauth_client_token" ADD CONSTRAINT "oauth_client_token_pkey" PRIMARY KEY ("authentication_id");

-- ----------------------------
-- Uniques structure for table sys_menu
-- ----------------------------
ALTER TABLE "public"."sys_menu" ADD CONSTRAINT "sys_menu_code_key" UNIQUE ("code");

-- ----------------------------
-- Primary Key structure for table sys_menu
-- ----------------------------
ALTER TABLE "public"."sys_menu" ADD CONSTRAINT "sys_menu_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table sys_privilege
-- ----------------------------
ALTER TABLE "public"."sys_privilege" ADD CONSTRAINT "sys_privilege_pkey" PRIMARY KEY ("role_id", "menu_id");

-- ----------------------------
-- Indexes structure for table sys_role
-- ----------------------------
CREATE UNIQUE INDEX "unique_role_name" ON "public"."sys_role" USING btree (
  "name" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE UNIQUE INDEX "unique_role_value" ON "public"."sys_role" USING btree (
  "value" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table sys_role
-- ----------------------------
ALTER TABLE "public"."sys_role" ADD CONSTRAINT "sys_role_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Uniques structure for table sys_user
-- ----------------------------
ALTER TABLE "public"."sys_user" ADD CONSTRAINT "sys_user_username_key" UNIQUE ("username");

-- ----------------------------
-- Primary Key structure for table sys_user
-- ----------------------------
ALTER TABLE "public"."sys_user" ADD CONSTRAINT "sys_user_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table sys_user_role
-- ----------------------------
ALTER TABLE "public"."sys_user_role" ADD CONSTRAINT "sys_user_role_pkey" PRIMARY KEY ("id");
