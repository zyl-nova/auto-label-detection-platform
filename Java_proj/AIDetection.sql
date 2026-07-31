/*
 Navicat Premium Data Transfer

 Source Server         : postgresql
 Source Server Type    : PostgreSQL
 Source Server Version : 160002 (160002)
 Source Host           : 192.168.254.128:5432
 Source Catalog        : AIDetection
 Source Schema         : public

 Target Server Type    : PostgreSQL
 Target Server Version : 160002 (160002)
 File Encoding         : 65001

 Date: 17/11/2024 22:19:22
*/


-- ----------------------------
-- Table structure for detection_target
-- ----------------------------
DROP TABLE IF EXISTS "public"."detection_target";
CREATE TABLE "public"."detection_target" (
  "id" int8 NOT NULL,
  "model_url" varchar(255) COLLATE "pg_catalog"."default",
  "name" varchar(255) COLLATE "pg_catalog"."default",
  "content_classes" json
)
;
COMMENT ON COLUMN "public"."detection_target"."model_url" IS '模型存储路径';
COMMENT ON COLUMN "public"."detection_target"."name" IS '名称';
COMMENT ON COLUMN "public"."detection_target"."content_classes" IS '检测目标所检测的类型，json格式为
{
     英文名称:{中文名称:展示图片地址}
}';

-- ----------------------------
-- Records of detection_target
-- ----------------------------

-- ----------------------------
-- Table structure for tasks
-- ----------------------------
DROP TABLE IF EXISTS "public"."tasks";
CREATE TABLE "public"."tasks" (
  "id" int8 NOT NULL,
  "name" varchar(255) COLLATE "pg_catalog"."default",
  "executor" varchar(255) COLLATE "pg_catalog"."default",
  "video_resource_type" int2,
  "video_resource_url" varchar(255) COLLATE "pg_catalog"."default",
  "start_time" date,
  "end_time" date,
  "accum_quantities" int8,
  "alarm_quantities" int8,
  "detection_target_id" int8,
  "dealed_video_url" varchar(255) COLLATE "pg_catalog"."default"
)
;
COMMENT ON COLUMN "public"."tasks"."name" IS '任务名称';
COMMENT ON COLUMN "public"."tasks"."executor" IS '执行人';
COMMENT ON COLUMN "public"."tasks"."video_resource_type" IS '0:摄像头   1:本地视频';
COMMENT ON COLUMN "public"."tasks"."video_resource_url" IS '如果video_resource_type为0，则是流媒体地址
如果video_resource_type为1，则是视频文件存放地址';
COMMENT ON COLUMN "public"."tasks"."accum_quantities" IS '累计件数';
COMMENT ON COLUMN "public"."tasks"."alarm_quantities" IS '告警件数';
COMMENT ON COLUMN "public"."tasks"."dealed_video_url" IS '深度学习处理完后的视频存放地址';

-- ----------------------------
-- Records of tasks
-- ----------------------------
INSERT INTO "public"."tasks" VALUES (1, '222', 'ced', NULL, NULL, '2024-11-01', NULL, NULL, NULL, NULL, NULL);
INSERT INTO "public"."tasks" VALUES (2, '333', 'ced', NULL, NULL, '2024-10-02', NULL, NULL, NULL, NULL, NULL);

-- ----------------------------
-- Primary Key structure for table detection_target
-- ----------------------------
ALTER TABLE "public"."detection_target" ADD CONSTRAINT "detection_target_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table tasks
-- ----------------------------
ALTER TABLE "public"."tasks" ADD CONSTRAINT "tasks_pkey" PRIMARY KEY ("id");
