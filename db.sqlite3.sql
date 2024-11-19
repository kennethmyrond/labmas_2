BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "django_migrations" (
	"id"	integer NOT NULL,
	"app"	varchar(255) NOT NULL,
	"name"	varchar(255) NOT NULL,
	"applied"	datetime NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "auth_group_permissions" (
	"id"	integer NOT NULL,
	"group_id"	integer NOT NULL,
	"permission_id"	integer NOT NULL,
	FOREIGN KEY("group_id") REFERENCES "auth_group"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("permission_id") REFERENCES "auth_permission"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "auth_user_groups" (
	"id"	integer NOT NULL,
	"user_id"	integer NOT NULL,
	"group_id"	integer NOT NULL,
	FOREIGN KEY("group_id") REFERENCES "auth_group"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "auth_user_user_permissions" (
	"id"	integer NOT NULL,
	"user_id"	integer NOT NULL,
	"permission_id"	integer NOT NULL,
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("permission_id") REFERENCES "auth_permission"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "account_emailconfirmation" (
	"id"	integer NOT NULL,
	"created"	datetime NOT NULL,
	"sent"	datetime,
	"key"	varchar(64) NOT NULL UNIQUE,
	"email_address_id"	integer NOT NULL,
	FOREIGN KEY("email_address_id") REFERENCES "account_emailaddress"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "django_content_type" (
	"id"	integer NOT NULL,
	"app_label"	varchar(100) NOT NULL,
	"model"	varchar(100) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "auth_permission" (
	"id"	integer NOT NULL,
	"content_type_id"	integer NOT NULL,
	"codename"	varchar(100) NOT NULL,
	"name"	varchar(255) NOT NULL,
	FOREIGN KEY("content_type_id") REFERENCES "django_content_type"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "auth_group" (
	"id"	integer NOT NULL,
	"name"	varchar(150) NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "auth_user" (
	"id"	integer NOT NULL,
	"password"	varchar(128) NOT NULL,
	"last_login"	datetime,
	"is_superuser"	bool NOT NULL,
	"username"	varchar(150) NOT NULL UNIQUE,
	"last_name"	varchar(150) NOT NULL,
	"email"	varchar(254) NOT NULL,
	"is_staff"	bool NOT NULL,
	"is_active"	bool NOT NULL,
	"date_joined"	datetime NOT NULL,
	"first_name"	varchar(150) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "core_module" (
	"id"	integer NOT NULL,
	"name"	varchar(50) NOT NULL,
	"enabled"	bool NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "django_session" (
	"session_key"	varchar(40) NOT NULL,
	"session_data"	text NOT NULL,
	"expire_date"	datetime NOT NULL,
	PRIMARY KEY("session_key")
);
CREATE TABLE IF NOT EXISTS "django_site" (
	"id"	integer NOT NULL,
	"name"	varchar(50) NOT NULL,
	"domain"	varchar(100) NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "socialaccount_socialapp_sites" (
	"id"	integer NOT NULL,
	"socialapp_id"	integer NOT NULL,
	"site_id"	integer NOT NULL,
	FOREIGN KEY("site_id") REFERENCES "django_site"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("socialapp_id") REFERENCES "socialaccount_socialapp"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "socialaccount_socialapp" (
	"id"	integer NOT NULL,
	"provider"	varchar(30) NOT NULL,
	"name"	varchar(40) NOT NULL,
	"client_id"	varchar(191) NOT NULL,
	"secret"	varchar(191) NOT NULL,
	"key"	varchar(191) NOT NULL,
	"provider_id"	varchar(200) NOT NULL,
	"settings"	text NOT NULL CHECK((JSON_VALID("settings") OR "settings" IS NULL)),
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "socialaccount_socialtoken" (
	"id"	integer NOT NULL,
	"token"	text NOT NULL,
	"token_secret"	text NOT NULL,
	"expires_at"	datetime,
	"account_id"	integer NOT NULL,
	"app_id"	integer,
	FOREIGN KEY("account_id") REFERENCES "socialaccount_socialaccount"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("app_id") REFERENCES "socialaccount_socialapp"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "core_permissions" (
	"permission_id"	integer NOT NULL,
	"codename"	varchar(45),
	"name"	varchar(45),
	"module_id"	bigint NOT NULL,
	FOREIGN KEY("module_id") REFERENCES "core_module"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("permission_id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "django_admin_log" (
	"id"	integer NOT NULL,
	"action_time"	datetime NOT NULL,
	"object_id"	text,
	"object_repr"	varchar(200) NOT NULL,
	"action_flag"	smallint unsigned NOT NULL CHECK("action_flag" >= 0),
	"change_message"	text NOT NULL,
	"content_type_id"	integer,
	"user_id"	varchar(20) NOT NULL,
	FOREIGN KEY("content_type_id") REFERENCES "django_content_type"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("user_id") REFERENCES "core_user"("user_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "account_emailaddress" (
	"id"	integer NOT NULL,
	"email"	varchar(254) NOT NULL,
	"verified"	bool NOT NULL,
	"primary"	bool NOT NULL,
	"user_id"	varchar(20) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "core_user"("user_id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "socialaccount_socialaccount" (
	"id"	integer NOT NULL,
	"provider"	varchar(200) NOT NULL,
	"uid"	varchar(191) NOT NULL,
	"last_login"	datetime NOT NULL,
	"date_joined"	datetime NOT NULL,
	"extra_data"	text NOT NULL CHECK((JSON_VALID("extra_data") OR "extra_data" IS NULL)),
	"user_id"	varchar(20) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "core_user"("user_id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "core_borrowed_items" (
	"id"	integer NOT NULL,
	"qty"	integer,
	"returned_qty"	integer NOT NULL,
	"remarks"	varchar(1),
	"borrow_id"	varchar(20) NOT NULL,
	"item_id"	varchar(20) NOT NULL,
	"unit"	varchar(10),
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("borrow_id") REFERENCES "core_borrow_info"("borrow_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("item_id") REFERENCES "core_item_description"("item_id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "core_laboratory" (
	"name"	varchar(45),
	"description"	varchar(45),
	"department"	varchar(45),
	"is_available"	bool NOT NULL,
	"date_created"	datetime NOT NULL,
	"modules"	text NOT NULL CHECK((JSON_VALID("modules") OR "modules" IS NULL)),
	"laboratory_id"	varchar(20) NOT NULL,
	PRIMARY KEY("laboratory_id")
);
CREATE TABLE IF NOT EXISTS "core_laboratory_permissions" (
	"id"	integer NOT NULL,
	"permissions_id"	integer NOT NULL,
	"laboratory_id"	varchar(20) NOT NULL,
	"role_id"	integer NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("laboratory_id") REFERENCES "core_laboratory"("laboratory_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("permissions_id") REFERENCES "core_permissions"("permission_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("role_id") REFERENCES "core_laboratory_roles"("roles_id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "core_item_types" (
	"itemType_id"	integer NOT NULL,
	"itemType_name"	varchar(45),
	"add_cols"	text NOT NULL,
	"is_consumable"	bool NOT NULL,
	"laboratory_id"	varchar(20) NOT NULL,
	PRIMARY KEY("itemType_id" AUTOINCREMENT),
	FOREIGN KEY("laboratory_id") REFERENCES "core_laboratory"("laboratory_id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "core_borrow_info" (
	"borrow_id"	varchar(20) NOT NULL,
	"request_date"	datetime,
	"borrow_date"	date,
	"due_date"	date,
	"status"	varchar(1),
	"questions_responses"	text NOT NULL CHECK((JSON_VALID("questions_responses") OR "questions_responses" IS NULL)),
	"remarks"	varchar(45),
	"approved_by_id"	varchar(20),
	"laboratory_id"	varchar(20) NOT NULL,
	"user_id"	varchar(20),
	FOREIGN KEY("laboratory_id") REFERENCES "core_laboratory"("laboratory_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("approved_by_id") REFERENCES "core_user"("user_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("user_id") REFERENCES "core_user"("user_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("borrow_id")
);
CREATE TABLE IF NOT EXISTS "core_borrowing_config" (
	"laboratory_id"	varchar(20) NOT NULL,
	"allow_walkin"	bool NOT NULL,
	"allow_prebook"	bool NOT NULL,
	"prebook_lead_time"	integer NOT NULL,
	"allow_shortterm"	bool NOT NULL,
	"allow_longterm"	bool NOT NULL,
	"questions_config"	text NOT NULL CHECK((JSON_VALID("questions_config") OR "questions_config" IS NULL)),
	FOREIGN KEY("laboratory_id") REFERENCES "core_laboratory"("laboratory_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("laboratory_id")
);
CREATE TABLE IF NOT EXISTS "core_laboratory_roles" (
	"roles_id"	integer NOT NULL,
	"name"	varchar(45),
	"laboratory_id"	varchar(20) NOT NULL,
	FOREIGN KEY("laboratory_id") REFERENCES "core_laboratory"("laboratory_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("roles_id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "core_reported_items" (
	"qty_reported"	integer NOT NULL,
	"report_reason"	varchar(255) NOT NULL,
	"amount_to_pay"	decimal,
	"reported_date"	datetime NOT NULL,
	"remarks"	text,
	"status"	integer NOT NULL,
	"borrow_id"	varchar(20),
	"item_id"	varchar(20),
	"report_id"	varchar(20) NOT NULL,
	"laboratory_id"	varchar(20) NOT NULL,
	"user_id"	varchar(20),
	FOREIGN KEY("borrow_id") REFERENCES "core_borrow_info"("borrow_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("user_id") REFERENCES "core_user"("user_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("item_id") REFERENCES "core_item_description"("item_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("report_id"),
	FOREIGN KEY("laboratory_id") REFERENCES "core_laboratory"("laboratory_id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "core_laboratory_users" (
	"id"	integer NOT NULL,
	"laboratory_id"	varchar(20) NOT NULL,
	"role_id"	integer NOT NULL,
	"user_id"	varchar(20) NOT NULL,
	"is_active"	bool NOT NULL,
	"status"	varchar(1) NOT NULL,
	"timestamp"	datetime,
	FOREIGN KEY("role_id") REFERENCES "core_laboratory_roles"("roles_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("laboratory_id") REFERENCES "core_laboratory"("laboratory_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("user_id") REFERENCES "core_user"("user_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "core_reservation_config" (
	"id"	integer NOT NULL,
	"reservation_type"	varchar(10) NOT NULL,
	"start_time"	time,
	"end_time"	time,
	"require_approval"	bool NOT NULL,
	"require_payment"	bool NOT NULL,
	"approval_form"	varchar(100),
	"leadtime"	integer unsigned NOT NULL CHECK("leadtime" >= 0),
	"laboratory_id"	varchar(20) NOT NULL,
	"tc_description"	text,
	FOREIGN KEY("laboratory_id") REFERENCES "core_laboratory"("laboratory_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "core_laboratory_reservations" (
	"reservation_id"	varchar(20) NOT NULL,
	"request_date"	datetime NOT NULL,
	"start_date"	date,
	"start_time"	time,
	"end_time"	time,
	"status"	varchar(1) NOT NULL,
	"purpose"	varchar(255),
	"num_people"	integer,
	"contact_email"	varchar(254),
	"contact_name"	varchar(255),
	"room_id"	varchar(20),
	"user_id"	varchar(20),
	"filled_approval_form"	varchar(100),
	"laboratory_id"	varchar(20) NOT NULL,
	FOREIGN KEY("laboratory_id") REFERENCES "core_laboratory"("laboratory_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("user_id") REFERENCES "core_user"("user_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("room_id") REFERENCES "core_rooms"("room_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("reservation_id")
);
CREATE TABLE IF NOT EXISTS "core_item_inventory" (
	"date_purchased"	datetime,
	"date_received"	datetime,
	"purchase_price"	real,
	"remarks"	varchar(45),
	"qty"	integer NOT NULL,
	"item_id"	varchar(20) NOT NULL,
	"supplier_id"	varchar(20),
	"inventory_item_id"	varchar(20) NOT NULL,
	FOREIGN KEY("supplier_id") REFERENCES "core_suppliers"("suppliers_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("item_id") REFERENCES "core_item_description"("item_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("inventory_item_id")
);
CREATE TABLE IF NOT EXISTS "core_item_expirations" (
	"expired_date"	date NOT NULL,
	"inventory_item_id"	varchar(20) NOT NULL,
	FOREIGN KEY("inventory_item_id") REFERENCES "core_item_inventory"("inventory_item_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("inventory_item_id")
);
CREATE TABLE IF NOT EXISTS "core_item_handling" (
	"item_handling_id"	integer NOT NULL,
	"timestamp"	datetime,
	"changes"	varchar(1) NOT NULL,
	"qty"	integer NOT NULL,
	"remarks"	varchar(45),
	"inventory_item_id"	varchar(20),
	"updated_by_id"	varchar(20),
	FOREIGN KEY("updated_by_id") REFERENCES "core_user"("user_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("inventory_item_id") REFERENCES "core_item_inventory"("inventory_item_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("item_handling_id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "core_suppliers" (
	"suppliers_id"	varchar(20) NOT NULL,
	"supplier_name"	varchar(45) NOT NULL,
	"contact_person"	varchar(45),
	"contact_number"	integer,
	"description"	varchar(45),
	"is_disabled"	bool NOT NULL,
	"laboratory_id"	varchar(20) NOT NULL,
	"email"	varchar(254) UNIQUE,
	FOREIGN KEY("laboratory_id") REFERENCES "core_laboratory"("laboratory_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("suppliers_id")
);
CREATE TABLE IF NOT EXISTS "core_user" (
	"password"	varchar(128) NOT NULL,
	"last_login"	datetime,
	"user_id"	varchar(20) NOT NULL,
	"firstname"	varchar(45) NOT NULL,
	"lastname"	varchar(45) NOT NULL,
	"email"	varchar(254) NOT NULL UNIQUE,
	"is_deactivated"	bool NOT NULL,
	"is_staff"	bool NOT NULL,
	"is_superuser"	bool NOT NULL,
	"date_joined"	datetime NOT NULL,
	"personal_id"	varchar(45),
	"username"	varchar(45),
	PRIMARY KEY("user_id")
);
CREATE TABLE IF NOT EXISTS "core_item_description" (
	"item_id"	varchar(20) NOT NULL,
	"item_name"	varchar(45),
	"alert_qty"	integer,
	"rec_expiration"	bool NOT NULL,
	"is_disabled"	bool NOT NULL,
	"allow_borrow"	bool NOT NULL,
	"is_consumable"	bool NOT NULL,
	"laboratory_id"	varchar(20),
	"itemType_id"	integer,
	"qty_limit"	integer,
	"rec_per_inv"	bool NOT NULL,
	"add_cols"	varchar(255),
	FOREIGN KEY("itemType_id") REFERENCES "core_item_types"("itemType_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("laboratory_id") REFERENCES "core_laboratory"("laboratory_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("item_id")
);
CREATE TABLE IF NOT EXISTS "core_rooms" (
	"room_id"	varchar(20) NOT NULL,
	"name"	varchar(45),
	"capacity"	integer NOT NULL,
	"description"	varchar(45),
	"is_disabled"	bool NOT NULL,
	"is_reservable"	bool NOT NULL,
	"laboratory_id"	varchar(20) NOT NULL,
	"blocked_time"	varchar(45) NOT NULL,
	FOREIGN KEY("laboratory_id") REFERENCES "core_laboratory"("laboratory_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("room_id")
);
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (1,'contenttypes','0001_initial','2024-09-23 07:03:22.123373');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (2,'auth','0001_initial','2024-09-23 07:03:22.199370');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (3,'account','0001_initial','2024-09-23 07:03:22.305370');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (4,'account','0002_email_max_length','2024-09-23 07:03:22.357368');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (5,'account','0003_alter_emailaddress_create_unique_verified_email','2024-09-23 07:03:22.416364');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (6,'account','0004_alter_emailaddress_drop_unique_email','2024-09-23 07:03:22.463372');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (7,'account','0005_emailaddress_idx_upper_email','2024-09-23 07:03:22.500542');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (8,'account','0006_emailaddress_lower','2024-09-23 07:03:22.544170');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (9,'account','0007_emailaddress_idx_email','2024-09-23 07:03:22.606329');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (10,'account','0008_emailaddress_unique_primary_email_fixup','2024-09-23 07:03:22.641423');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (11,'account','0009_emailaddress_unique_primary_email','2024-09-23 07:03:22.680052');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (12,'admin','0001_initial','2024-09-23 07:03:22.717135');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (13,'admin','0002_logentry_remove_auto_add','2024-09-23 07:03:22.764799');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (14,'admin','0003_logentry_add_action_flag_choices','2024-09-23 07:03:22.791857');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (15,'contenttypes','0002_remove_content_type_name','2024-09-23 07:03:22.862570');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (16,'auth','0002_alter_permission_name_max_length','2024-09-23 07:03:22.905715');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (17,'auth','0003_alter_user_email_max_length','2024-09-23 07:03:22.950907');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (18,'auth','0004_alter_user_username_opts','2024-09-23 07:03:22.974995');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (19,'auth','0005_alter_user_last_login_null','2024-09-23 07:03:23.016079');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (20,'auth','0006_require_contenttypes_0002','2024-09-23 07:03:23.025620');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (21,'auth','0007_alter_validators_add_error_messages','2024-09-23 07:03:23.051678');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (22,'auth','0008_alter_user_username_max_length','2024-09-23 07:03:23.092221');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (23,'auth','0009_alter_user_last_name_max_length','2024-09-23 07:03:23.152087');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (24,'auth','0010_alter_group_name_max_length','2024-09-23 07:03:23.336422');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (25,'auth','0011_update_proxy_permissions','2024-09-23 07:03:23.447416');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (26,'auth','0012_alter_user_first_name_max_length','2024-09-23 07:03:23.489415');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (27,'core','0001_initial','2024-09-23 07:03:23.539418');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (28,'sessions','0001_initial','2024-09-23 07:03:23.575425');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (29,'sites','0001_initial','2024-09-23 07:03:23.608423');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (30,'sites','0002_alter_domain_unique','2024-09-23 07:03:23.657422');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (31,'socialaccount','0001_initial','2024-09-23 07:03:23.869413');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (32,'socialaccount','0002_token_max_lengths','2024-09-23 07:03:23.956412');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (33,'socialaccount','0003_extra_data_default_dict','2024-09-23 07:03:23.982408');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (34,'socialaccount','0004_app_provider_id_settings','2024-09-23 07:03:24.060415');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (35,'socialaccount','0005_socialtoken_nullable_app','2024-09-23 07:03:24.120421');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (36,'socialaccount','0006_alter_socialaccount_extra_data','2024-09-23 07:03:24.186415');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (37,'core','0002_item_types_suppliers_item_description_item_inventory_and_more','2024-09-23 07:16:08.848723');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (38,'core','0003_item_inventory_amount_item_inventory_qty','2024-09-23 11:20:15.648686');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (39,'core','0004_rename_alert_qty_item_description_qty','2024-09-24 09:18:42.796188');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (40,'core','0005_item_transactions_remarks','2024-09-24 09:20:39.441393');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (41,'core','0006_remove_item_inventory_amount_and_more','2024-09-24 09:27:23.933301');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (42,'core','0007_item_description_alert_qty','2024-09-24 10:20:04.107223');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (43,'core','0008_item_description_disabled','2024-09-25 09:25:28.394539');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (44,'core','0009_suppliers_laboratory_id','2024-09-25 13:46:29.215340');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (45,'core','0010_alter_item_types_laboratory_id','2024-09-25 13:47:18.869264');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (46,'core','0011_rename_laboratory_id_item_types_laboratory_and_more','2024-09-25 13:48:18.712881');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (47,'core','0012_suppliers_description_alter_suppliers_suppliername','2024-09-25 13:52:34.317358');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (48,'core','0013_rename_suppliername_suppliers_supplier_name','2024-09-25 14:01:10.614008');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (49,'core','0014_suppliers_address_suppliers_contactperson_and_more','2024-09-26 11:21:17.145554');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (50,'core','0015_item_expirations','2024-09-26 12:02:17.550711');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (51,'core','0002_remove_item_description_end_username_and_more','2024-09-27 12:09:41.536402');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (52,'core','0003_rename_disabled_item_description_is_disabled_and_more','2024-09-27 13:37:12.587149');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (53,'core','0004_item_handling_action_alter_item_handling_updated_on','2024-09-28 08:58:59.693417');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (54,'core','0004_alter_item_handling_updated_on_and_more','2024-09-28 16:59:47.122501');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (55,'core','0005_borrow_info','2024-09-30 12:46:10.034879');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (56,'core','0006_borrowed_items','2024-09-30 12:46:55.654869');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (57,'core','0007_borrow_info_approved_by_and_more','2024-10-01 06:21:25.194099');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (58,'core','0008_alter_borrow_info_user','2024-10-02 12:56:29.022710');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (59,'core','0009_borrowing_config','2024-10-02 14:06:41.792816');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (60,'core','0010_alter_borrowing_config_laboratory','2024-10-02 14:09:13.803984');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (61,'core','0011_remove_item_description_amount_and_more','2024-10-03 11:45:49.982701');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (62,'core','0012_item_description_is_consumable','2024-10-03 12:43:04.216439');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (63,'core','0013_item_types_is_consumable','2024-10-03 13:00:16.515247');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (64,'core','0014_rename_address_suppliers_contact_person_and_more','2024-10-03 13:52:07.885995');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (65,'core','0015_borrowing_config_questions_config','2024-10-05 09:33:16.319824');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (66,'core','0016_alter_borrowing_config_questions_config','2024-10-05 09:45:58.807800');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (67,'core','0017_alter_borrowing_config_prebook_lead_time','2024-10-05 14:25:51.033990');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (68,'core','0018_borrow_info_questions_responses','2024-10-06 06:19:57.616871');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (69,'core','0019_borrowed_items_remarks_borrowed_items_returned_qty','2024-10-08 13:24:47.605689');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (70,'core','0020_alter_borrowed_items_returned_qty','2024-10-08 13:27:53.189645');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (71,'core','0021_reported_items','2024-10-08 14:24:34.974143');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (72,'core','0022_borrow_info_remarks','2024-10-08 17:23:27.141451');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (73,'core','0023_reported_items_status','2024-10-13 15:21:03.286800');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (74,'core','0024_reported_items_remarks','2024-10-13 15:21:03.312128');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (75,'core','0025_user_id_number','2024-10-13 15:21:03.331132');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (76,'core','0026_item_handling_remarks','2024-10-16 11:31:35.720528');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (77,'core','0027_suppliers_is_disabled','2024-10-17 08:55:32.296674');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (78,'core','0028_rooms_laboratory_reservations','2024-10-18 05:43:56.133985');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (79,'core','0029_rooms_capacity','2024-10-18 05:50:48.444121');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (80,'core','0030_remove_laboratory_reservations_approved_by_and_more','2024-10-18 17:04:38.071374');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (81,'core','0031_roomconfiguration_timeconfiguration_blockedtime','2024-10-21 11:32:25.666456');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (82,'core','0032_rename_blockedtime_reservation_blocked_and_more','2024-10-21 11:34:05.299395');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (83,'core','0033_rooms_is_reservable_delete_room_configuration','2024-10-21 11:38:23.779240');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (84,'core','0034_reservation_blocked_room_rooms_blocked_time_and_more','2024-10-22 09:23:25.083780');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (85,'core','0035_remove_time_configuration_room_remove_rooms_end_time_and_more','2024-10-22 15:59:23.686959');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (86,'core','0036_reservation_config_tc_description','2024-10-22 17:01:46.616741');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (87,'core','0037_reservation_config_approval_form_and_more','2024-10-22 17:24:14.556934');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (88,'core','0038_reservation_config_leadtime','2024-10-23 07:43:17.185460');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (89,'core','0039_remove_laboratory_reservations_contact_number','2024-10-23 12:21:15.294972');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (90,'core','0040_remove_item_handling_updated_on_and_more','2024-10-24 11:07:54.063043');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (91,'core','0041_laboratory_modules_laboratorymodule','2024-10-26 02:04:19.519933');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (92,'core','0002_laboratory_date_created','2024-10-26 06:07:51.963340');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (93,'core','0003_laboratorymodule_enabled','2024-10-26 08:07:42.757835');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (94,'core','0004_remove_user_role_rename_role_laboratory_role_and_more','2024-10-26 17:16:02.650776');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (95,'core','0005_laboratory_role_is_active_laboratory_users_is_active','2024-10-28 09:08:29.317182');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (96,'core','0006_remove_user_id_number_remove_user_is_active_and_more','2024-10-28 09:45:35.203032');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (97,'core','0007_user_personal_id','2024-10-28 10:10:00.893936');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (98,'core','0008_user_username','2024-10-28 10:17:23.970030');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (99,'core','0009_alter_user_username','2024-10-29 16:05:58.724967');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (100,'core','0010_remove_laboratory_modules_laboratory_modules','2024-10-29 16:09:40.685950');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (101,'core','0011_delete_laboratorymodule','2024-10-29 16:48:29.573314');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (102,'core','0012_remove_borrow_info_user_and_more','2024-10-29 18:05:21.444718');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (103,'core','0013_borrow_info_user','2024-10-29 18:05:21.515136');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (104,'core','0014_laboratory_roles_laboratory_permissions_and_more','2024-10-30 10:47:42.630941');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (105,'core','0015_rename_laboratory_roles_laboratory_role','2024-10-30 10:47:42.709944');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (106,'core','0016_rename_laboratory_role_laboratory_roles','2024-10-30 10:47:42.835536');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (107,'core','0017_rename_role_id_laboratory_permissions_role','2024-10-30 10:49:16.871297');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (108,'core','0018_permissions_and_more','2024-10-30 10:58:43.061155');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (109,'core','0019_alter_laboratory_permissions_unique_together_and_more','2024-10-30 11:07:38.247230');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (110,'core','0020_delete_item_transactions','2024-11-05 09:32:56.221943');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (111,'core','0021_alter_permissions_module','2024-11-05 09:36:14.272805');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (112,'core','0022_laboratory_roles_laboratory','2024-11-05 11:42:13.454325');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (113,'core','0023_user_groups_user_user_permissions','2024-11-05 17:26:24.382483');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (114,'core','0024_remove_user_groups_remove_user_user_permissions','2024-11-05 17:26:33.115301');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (115,'core','0025_alter_user_user_id','2024-11-06 11:10:44.227468');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (116,'core','0026_remove_reported_items_id_reported_items_reference_id_and_more','2024-11-06 11:30:48.674996');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (117,'core','0027_alter_item_expirations_expired_date_and_more','2024-11-09 06:13:54.151175');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (118,'core','0028_rename_reference_id_reported_items_report_id','2024-11-10 07:46:49.932832');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (119,'core','0029_reported_items_laboratory','2024-11-10 07:55:56.274146');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (120,'core','0030_alter_reported_items_borrow_and_more','2024-11-10 16:04:12.648111');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (121,'core','0031_reported_items_user','2024-11-10 16:05:41.380313');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (122,'core','0032_alter_laboratory_laboratory_id','2024-11-10 16:39:23.124181');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (123,'core','0033_alter_rooms_room_id','2024-11-10 16:43:52.364119');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (124,'core','0030_alter_reported_items_borrow','2024-11-10 18:47:18.739038');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (125,'core','0034_merge_20241111_0246','2024-11-10 18:47:18.752066');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (126,'core','0035_alter_reported_items_user','2024-11-10 18:48:22.356307');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (127,'core','0036_laboratory_users_status','2024-11-12 13:09:57.347080');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (128,'core','0037_laboratory_users_timestamp','2024-11-12 13:14:30.318546');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (129,'core','0038_laboratory_reservations_filled_approval_form','2024-11-12 16:02:07.638311');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (130,'core','0039_alter_reservation_config_tc_description','2024-11-12 16:12:21.944496');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (131,'core','0040_alter_suppliers_suppliers_id','2024-11-13 06:53:16.616020');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (132,'core','0041_alter_laboratory_reservations_room','2024-11-13 11:33:42.445592');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (133,'core','0042_laboratory_reservations_laboratory','2024-11-13 11:44:18.291988');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (134,'core','0043_alter_item_inventory_inventory_item_id','2024-11-14 11:37:23.262325');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (135,'core','0044_suppliers_email','2024-11-14 15:11:08.543922');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (136,'core','0045_borrowed_items_unit','2024-11-15 11:29:56.196738');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (137,'core','0046_item_description_is_limited','2024-11-16 07:41:35.072467');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (138,'core','0046_item_description_qty_limit','2024-11-16 11:21:46.082168');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (139,'core','0047_item_description_count_per_inventory','2024-11-16 11:34:18.245856');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (140,'core','0048_rename_count_per_inventory_item_description_rec_per_inv','2024-11-16 11:44:23.593464');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (141,'core','0047_merge_20241116_1916','2024-11-16 12:04:39.589226');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (142,'core','0049_item_description_count_per_inventory','2024-11-16 12:04:39.626223');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (143,'core','0050_rename_count_per_inventory_item_description_rec_per_inv','2024-11-16 12:04:39.662227');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (144,'core','0051_alter_user_username','2024-11-16 13:57:27.991913');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (145,'core','0052_alter_item_description_add_cols','2024-11-17 12:03:45.239172');
INSERT INTO "django_migrations" ("id","app","name","applied") VALUES (146,'core','0053_alter_rooms_blocked_time','2024-11-18 16:15:55.726849');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (1,'admin','logentry');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (2,'auth','permission');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (3,'auth','group');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (4,'auth','user');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (5,'contenttypes','contenttype');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (6,'sessions','session');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (7,'core','laboratory');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (8,'core','module');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (9,'core','laboratory_roles');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (10,'core','user');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (11,'sites','site');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (12,'account','emailaddress');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (13,'account','emailconfirmation');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (14,'socialaccount','socialaccount');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (15,'socialaccount','socialapp');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (16,'socialaccount','socialtoken');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (17,'core','item_description');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (18,'core','item_handling');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (19,'core','item_inventory');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (20,'core','item_transactions');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (21,'core','item_types');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (22,'core','suppliers');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (23,'core','item_expirations');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (24,'core','borrow_info');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (25,'core','borrowed_items');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (26,'core','borrowing_config');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (27,'core','reported_items');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (28,'core','laboratory_reservations');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (29,'core','rooms');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (30,'core','room_configuration');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (31,'core','time_configuration');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (32,'core','reservation_blocked');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (33,'core','reservation_config');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (34,'core','laboratorymodule');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (35,'core','laboratory_users');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (36,'core','laboratory_permissions');
INSERT INTO "django_content_type" ("id","app_label","model") VALUES (37,'core','permissions');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (1,1,'add_logentry','Can add log entry');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (2,1,'change_logentry','Can change log entry');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (3,1,'delete_logentry','Can delete log entry');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (4,1,'view_logentry','Can view log entry');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (5,2,'add_permission','Can add permission');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (6,2,'change_permission','Can change permission');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (7,2,'delete_permission','Can delete permission');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (8,2,'view_permission','Can view permission');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (9,3,'add_group','Can add group');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (10,3,'change_group','Can change group');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (11,3,'delete_group','Can delete group');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (12,3,'view_group','Can view group');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (13,4,'add_user','Can add user');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (14,4,'change_user','Can change user');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (15,4,'delete_user','Can delete user');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (16,4,'view_user','Can view user');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (17,5,'add_contenttype','Can add content type');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (18,5,'change_contenttype','Can change content type');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (19,5,'delete_contenttype','Can delete content type');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (20,5,'view_contenttype','Can view content type');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (21,6,'add_session','Can add session');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (22,6,'change_session','Can change session');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (23,6,'delete_session','Can delete session');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (24,6,'view_session','Can view session');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (25,7,'add_laboratory','Can add laboratory');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (26,7,'change_laboratory','Can change laboratory');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (27,7,'delete_laboratory','Can delete laboratory');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (28,7,'view_laboratory','Can view laboratory');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (29,8,'add_module','Can add module');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (30,8,'change_module','Can change module');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (31,8,'delete_module','Can delete module');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (32,8,'view_module','Can view module');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (33,9,'add_role','Can add role');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (34,9,'change_role','Can change role');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (35,9,'delete_role','Can delete role');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (36,9,'view_role','Can view role');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (37,10,'add_user','Can add user');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (38,10,'change_user','Can change user');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (39,10,'delete_user','Can delete user');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (40,10,'view_user','Can view user');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (41,11,'add_site','Can add site');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (42,11,'change_site','Can change site');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (43,11,'delete_site','Can delete site');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (44,11,'view_site','Can view site');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (45,12,'add_emailaddress','Can add email address');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (46,12,'change_emailaddress','Can change email address');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (47,12,'delete_emailaddress','Can delete email address');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (48,12,'view_emailaddress','Can view email address');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (49,13,'add_emailconfirmation','Can add email confirmation');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (50,13,'change_emailconfirmation','Can change email confirmation');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (51,13,'delete_emailconfirmation','Can delete email confirmation');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (52,13,'view_emailconfirmation','Can view email confirmation');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (53,14,'add_socialaccount','Can add social account');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (54,14,'change_socialaccount','Can change social account');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (55,14,'delete_socialaccount','Can delete social account');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (56,14,'view_socialaccount','Can view social account');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (57,15,'add_socialapp','Can add social application');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (58,15,'change_socialapp','Can change social application');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (59,15,'delete_socialapp','Can delete social application');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (60,15,'view_socialapp','Can view social application');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (61,16,'add_socialtoken','Can add social application token');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (62,16,'change_socialtoken','Can change social application token');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (63,16,'delete_socialtoken','Can delete social application token');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (64,16,'view_socialtoken','Can view social application token');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (65,17,'add_item_description','Can add item_description');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (66,17,'change_item_description','Can change item_description');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (67,17,'delete_item_description','Can delete item_description');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (68,17,'view_item_description','Can view item_description');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (69,18,'add_item_handling','Can add item_handling');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (70,18,'change_item_handling','Can change item_handling');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (71,18,'delete_item_handling','Can delete item_handling');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (72,18,'view_item_handling','Can view item_handling');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (73,19,'add_item_inventory','Can add item_inventory');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (74,19,'change_item_inventory','Can change item_inventory');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (75,19,'delete_item_inventory','Can delete item_inventory');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (76,19,'view_item_inventory','Can view item_inventory');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (77,20,'add_item_transactions','Can add item_transactions');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (78,20,'change_item_transactions','Can change item_transactions');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (79,20,'delete_item_transactions','Can delete item_transactions');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (80,20,'view_item_transactions','Can view item_transactions');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (81,21,'add_item_types','Can add item_types');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (82,21,'change_item_types','Can change item_types');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (83,21,'delete_item_types','Can delete item_types');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (84,21,'view_item_types','Can view item_types');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (85,22,'add_suppliers','Can add suppliers');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (86,22,'change_suppliers','Can change suppliers');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (87,22,'delete_suppliers','Can delete suppliers');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (88,22,'view_suppliers','Can view suppliers');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (89,23,'add_item_expirations','Can add item_expirations');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (90,23,'change_item_expirations','Can change item_expirations');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (91,23,'delete_item_expirations','Can delete item_expirations');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (92,23,'view_item_expirations','Can view item_expirations');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (93,24,'add_borrow_info','Can add borrow_info');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (94,24,'change_borrow_info','Can change borrow_info');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (95,24,'delete_borrow_info','Can delete borrow_info');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (96,24,'view_borrow_info','Can view borrow_info');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (97,25,'add_borrowed_items','Can add borrowed_items');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (98,25,'change_borrowed_items','Can change borrowed_items');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (99,25,'delete_borrowed_items','Can delete borrowed_items');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (100,25,'view_borrowed_items','Can view borrowed_items');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (101,26,'add_borrowing_config','Can add borrowing_config');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (102,26,'change_borrowing_config','Can change borrowing_config');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (103,26,'delete_borrowing_config','Can delete borrowing_config');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (104,26,'view_borrowing_config','Can view borrowing_config');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (105,27,'add_reported_items','Can add reported_items');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (106,27,'change_reported_items','Can change reported_items');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (107,27,'delete_reported_items','Can delete reported_items');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (108,27,'view_reported_items','Can view reported_items');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (109,28,'add_laboratory_reservations','Can add laboratory_reservations');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (110,28,'change_laboratory_reservations','Can change laboratory_reservations');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (111,28,'delete_laboratory_reservations','Can delete laboratory_reservations');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (112,28,'view_laboratory_reservations','Can view laboratory_reservations');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (113,29,'add_rooms','Can add rooms');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (114,29,'change_rooms','Can change rooms');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (115,29,'delete_rooms','Can delete rooms');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (116,29,'view_rooms','Can view rooms');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (117,30,'add_roomconfiguration','Can add room configuration');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (118,30,'change_roomconfiguration','Can change room configuration');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (119,30,'delete_roomconfiguration','Can delete room configuration');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (120,30,'view_roomconfiguration','Can view room configuration');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (121,31,'add_timeconfiguration','Can add time configuration');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (122,31,'change_timeconfiguration','Can change time configuration');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (123,31,'delete_timeconfiguration','Can delete time configuration');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (124,31,'view_timeconfiguration','Can view time configuration');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (125,32,'add_blockedtime','Can add blocked time');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (126,32,'change_blockedtime','Can change blocked time');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (127,32,'delete_blockedtime','Can delete blocked time');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (128,32,'view_blockedtime','Can view blocked time');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (129,32,'add_reservation_blocked','Can add reservation_blocked');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (130,32,'change_reservation_blocked','Can change reservation_blocked');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (131,32,'delete_reservation_blocked','Can delete reservation_blocked');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (132,32,'view_reservation_blocked','Can view reservation_blocked');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (133,30,'add_room_configuration','Can add room_configuration');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (134,30,'change_room_configuration','Can change room_configuration');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (135,30,'delete_room_configuration','Can delete room_configuration');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (136,30,'view_room_configuration','Can view room_configuration');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (137,31,'add_time_configuration','Can add time_configuration');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (138,31,'change_time_configuration','Can change time_configuration');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (139,31,'delete_time_configuration','Can delete time_configuration');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (140,31,'view_time_configuration','Can view time_configuration');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (141,33,'add_reservation_config','Can add reservation_config');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (142,33,'change_reservation_config','Can change reservation_config');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (143,33,'delete_reservation_config','Can delete reservation_config');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (144,33,'view_reservation_config','Can view reservation_config');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (145,34,'add_laboratorymodule','Can add laboratory module');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (146,34,'change_laboratorymodule','Can change laboratory module');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (147,34,'delete_laboratorymodule','Can delete laboratory module');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (148,34,'view_laboratorymodule','Can view laboratory module');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (149,9,'add_laboratory_role','Can add laboratory_role');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (150,9,'change_laboratory_role','Can change laboratory_role');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (151,9,'delete_laboratory_role','Can delete laboratory_role');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (152,9,'view_laboratory_role','Can view laboratory_role');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (153,35,'add_laboratory_users','Can add laboratory_users');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (154,35,'change_laboratory_users','Can change laboratory_users');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (155,35,'delete_laboratory_users','Can delete laboratory_users');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (156,35,'view_laboratory_users','Can view laboratory_users');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (157,36,'add_laboratory_permissions','Can add laboratory_permissions');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (158,36,'change_laboratory_permissions','Can change laboratory_permissions');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (159,36,'delete_laboratory_permissions','Can delete laboratory_permissions');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (160,36,'view_laboratory_permissions','Can view laboratory_permissions');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (161,9,'add_laboratory_roles','Can add laboratory_roles');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (162,9,'change_laboratory_roles','Can change laboratory_roles');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (163,9,'delete_laboratory_roles','Can delete laboratory_roles');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (164,9,'view_laboratory_roles','Can view laboratory_roles');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (165,37,'add_permissions','Can add permissions');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (166,37,'change_permissions','Can change permissions');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (167,37,'delete_permissions','Can delete permissions');
INSERT INTO "auth_permission" ("id","content_type_id","codename","name") VALUES (168,37,'view_permissions','Can view permissions');
INSERT INTO "auth_user" ("id","password","last_login","is_superuser","username","last_name","email","is_staff","is_active","date_joined","first_name") VALUES (1,'pbkdf2_sha256$870000$qXoC7cPoXqZUIiaQAkRNyO$vOX6yIKqErYzDOnFkKBdYgI9oukDg9FAImF967Lp7uc=','2024-10-29 17:47:47.414038',1,'admin','','',1,1,'2024-09-23 07:03:50.944101','System');
INSERT INTO "auth_user" ("id","password","last_login","is_superuser","username","last_name","email","is_staff","is_active","date_joined","first_name") VALUES (2,'!2CxPnZMSy3FkMlo1fCvp3Hwx5Ngac71RpJD2e9hZ','2024-10-30 08:50:39.969135',0,'kenneth_myrond','Uy','kenneth_uy@dlsu.edu.ph',0,1,'2024-09-23 07:06:40.958816','Kenneth Myrond');
INSERT INTO "auth_user" ("id","password","last_login","is_superuser","username","last_name","email","is_staff","is_active","date_joined","first_name") VALUES (3,'!Ogbec2ocPgU7TpNkwB8xj5ESfV6JtTQMrxOp3M90','2024-10-26 03:19:39.412034',0,'luis','Ostia','luis_ostia@dlsu.edu.ph',0,1,'2024-09-23 11:10:21.645736','Luis');
INSERT INTO "auth_user" ("id","password","last_login","is_superuser","username","last_name","email","is_staff","is_active","date_joined","first_name") VALUES (4,'!XcFf7GC9W15aK5sJwDuv0BvWN5X53eOF6uYvcEyM','2024-10-25 15:59:43.526605',0,'dominique','Conde','dominique_conde@dlsu.edu.ph',0,1,'2024-10-06 16:22:08.136165','Dominique');
INSERT INTO "core_module" ("id","name","enabled") VALUES (1,'Inventory',1);
INSERT INTO "core_module" ("id","name","enabled") VALUES (2,'Borrowing',1);
INSERT INTO "core_module" ("id","name","enabled") VALUES (3,'Clearance',1);
INSERT INTO "core_module" ("id","name","enabled") VALUES (4,'Lab Reservation',1);
INSERT INTO "core_module" ("id","name","enabled") VALUES (5,'Reports',1);
INSERT INTO "core_module" ("id","name","enabled") VALUES (6,'Laboratory Setup',1);
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('5q6z2m7nnr7p6h0bjgjojcjq6vz8f4pp','.eJxVjUEOgjAURK9iujakQGmpS93qGZrf_o-g0CZtWRDj3YWEhWzfzLz5MANz7s2cKJoB2YWV7PzPLLg3-S3AF_hnKFzwOQ622CrFnqbiEZDG6949CHpI_brmWHdO1RWqhpCXsnWdblDUuhUdEdeATdUohZWCzkqhBJdct1JXUtiWqF6liUZymdCMYNmlPALjYaL159bTNKQcl9MdbIiQQ1zY9wdP_EzS:1stMUi:jltrb1LRmuPLD_G8bJuZydncybb2mPRgQrSIW1nRFT8','2024-10-09 07:31:28.195957');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('i8yoleiv93slqvu6goali01vbenk8mcg','.eJxVUMtqhTAQ_ZWStUiSm4e6a7vtH5QSJsl4laummFi4iP_eaO3CzTCc1zxWEoPrYQDnwjIlExMkjKRZt4L8Y7CkDqfUO0h9mMyIqQs-az5X8teT5ppCsjeRhmmumdJKiZJV7MaYKMj3HH56j3O23EO4D5i1S78nMFpRrUQugmktqKJaKrJ9FeRYwCwRZ3MoOblgFtwDp52AYdjh8lyjPDQnHcvXyxlvp-sS1UHsco5tlQfrpPVcyxq4oCC5okjR6pZJKWrnlLeI4AA51DffshpkWwmsUKn9pogDuoTeDGDzJ66AmWDEPOe9w7GPaX6-fIANM6QwP8n2CyS7hyI:1st2h1:G4XeuMaUWOAimxOFEYDlgbao7JNgIETFPRPbCyYhBrM','2024-10-08 10:22:51.368876');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('esg5sta501vrjxx6pxhkrtmdlqngx1v7','.eJxVUM1qhDAQfpUyZ5EYTWK8tb32DUqRSTKuUjUliYVl2XdvtF68DMP3Nz8PQGv9tqYetzTSmiaLafJrv1AavYvQfT7gv4cOorcTzqcDCsAEXaW4klq1dVVqUWsleQE_wf9OjkK23Ly_zZS127QnVKxlSja5NJVSDZNMCQnPrwKOBfotUugPJYcLZtB-07oTOM87XJ5rlIfmpGP5ejnj7XRdokaMY84xg3RorDCOK6GRNwwFl4wYGTVUQjTaWukMEVokjrp2Q6VRDG1DLUm53xRpJpvI9TOa_Ikr0K-4UJ7zPtIyxRTuLx9ofMDkwx2efwGufT8:1svF86:Z6FK-O8sfONzGPNv4I8Yg4-VGD0gqqxHqw80dCWrn7o','2024-10-14 12:03:54.542953');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('yd6lr55ova6qxsugn34u6n6hm0x27pbv','.eJxVjcsOgyAQRX-lYd0YROThru22_0AGGAOpYiK4ME3_vdq4qMt77sy5b2JgKcEsGWcTPelITa7_zIJ7YdoLGIYdV-DctKRS_W6OOle3LWEq0UGJU7ofXydVgBw2D_VN72TDvGzR01oo1-vW80Yr3iNSDb5lrZSeSeit4JJTQbUSmgluFWKzSTMO6Ap6M4AlXX0GJsGI284j4BhzmdfLE-w0Q5nmlXy-MzdRRg:1svG1p:Jlm3HVhfL3WbIstbfNV_-dIEISvmZAWVZYtsPdFPH1Q','2024-10-14 13:01:29.858436');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('9mc4exgmmehq1cn6dntf489b5umw8lh7','.eJxVUEtrhDAQ_itlziIxm4fure21_6CUMEnGVRpNMbGwLPvfG60XL8PwvebxAHQurnM2uOaB5jw6zGOczUR5iD7B9fMB_z1cIUU3YjgcUAFmuDaat4x1TIm6vTRcqq6CnyX-jp6WYrnFeAtUtOu4JTSsZVqJUkSjtWCKaang-VXBvoBZEy1mV3I4YRbdN80bgSFscH2sUe-ag0716-mMt8N1ihowDSXH9sqjddJ6rmWHXDCUXDFiZHXfSCk655S3ROiQOHYX3zcdyr4V1JJS202JArlM3gS05RNnwMw4UZnzPtA0przcXz7QxgVzXO7w_APonX0q:1sz4Vd:QB2chkKa8HYV6aIr_QyL3yi2sBSwzAC2yemvcFKkjao','2024-10-25 01:32:01.908187');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('ag4pn44lz97qjomtt3f7tkohqsytt1nx','.eJxVj8FqwzAMhl-l6FxCUofZya3dde9gZFkmZo4NtjMIpe8-d2SHHPX9vz6hJ5REHgMSpS1WXSpWLjA_X1f4Zz-cvfNsNa_oA8xxC-EKGre66K1w1t7CDCOcmEH65vgOMIQ37g5d99c54tLd28SxesLqU3wcWyfVgmVpHklqMmroFRvh-smpnpwyH0I6MdzMKJUTiMJaNY1jrywrIZkJbxKFm9C5Ji0cmGr7JKCBeTgDHXHldudz4dWXmvfLF5qUsaa8w-sXEcRnxw:1sxU1M:5ZfK0D527RW3gCWJSNXVXpoG2YIJMcdEUWeLB6g2fP0','2024-10-20 16:22:12.470302');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('cxjymzcff6n11wsb4k793fo8savi0ldt','.eJxVUEtuhDAMvUqVNUIh5AOza7vtDaoKOYkZogmkIqHSCHH3BkoXbCzr-X1sryQG48CDMWGZUhcTJIzktm4F-cdgSQNOyRlILkzdiGkINnM-V_LXk9vVhWRtIrdKsUbWopWyZIw2dV2Q7zn8OItzVtxDuHvM1MXtBhVtqJI8F14pxamkSkiyfRXkyO-WiHN3MBm5YBrMA6d9AN7vcHluUR6ccxzL18sVb6fqYjVAHLKP7qUFbYS2TIkWGKcgmKRIUau-EoK3xkirEcEAMmhr21ctiL7h2KCU-00RPZqEtvOg8yOuQDfBiDnnfcDRxTQ_Xz5AhxlSmJ9k-wXNm4b3:1t0Hk1:LKlGccPuzCqdeNVzt4Tm-qnyGNtWJ1D6gMYFPb8r6CU','2024-10-28 09:51:53.162681');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('pqti2sj0fr39fp8ctu54xa3sreqftpne','.eJw1y7EKwjAQANB_uTloW22jXd2Kow4iEsL1lNCQtMlFlJB_t4vz42WIHo22GtEnxyqyZorQZxjSdaHhy5fT2Sz6JqG_Z5iDR4qrg_Uv40DAqFlD75K1AuYJSaEfSb0pmKeh8BdHH17TFoqoZXM4tp1s6k23q6p2_yjlB5ddLNU:1t0Wcj:B3wuLLncLzViYWVvI6A48tfpOZx1LVGX4gmHmAP2PKE','2024-10-29 01:45:21.633052');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('bv6sp6k3tmp13a551pmes08dl7hpm37l','.eJxVUMtuhSAQ_ZWGtTFABfTu2m77B01jBhivpCgNYJMb478XrV24mUzOax4rScE48GBMWObcpwwZE7mtW0X-MVjyiHN2BrILcz9hHoMtmo-V_PXkdk0hxZvJjSneUUU5lbVkgknFKvIdw4-zGIvlHsLdY9Eubk9gtKVKNqU0TKmGSqqEJNtnRY4F-iVh7A8lJxdMg_nCeSfA-x2uzzXqQ3PSqX65nPF6ui5RI6Sx5OhBWtBGaMuV6IA3FASXFClqNTAhms4YaTUiGEAO3bMdWAdiaBtsUcr9poQeTUbbe9DlE1egn2HCMudtxMmlHB9P76BDhBzig2y_HpKHHQ:1t1qyG:yEdH-bAheCpF5m1dsSm2zO0lEZT6GlMk7RM6RrbHHN0','2024-11-01 17:41:04.118575');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('r05d27ec6ozsohqem4b94irlxyjkbyos','.eJxVUM1qhDAQfpUyZ5EYTWK8tb32DUqRSTKuUjUliYVl2XdvtF68DMP3Nz8PQGv9tqYetzTSmiaLafJrv1AavYvQfT7gv4cOorcTzqcDCsAEXaW4VlJoXZdCtnXFZQE_wf9OjkK23Ly_zZS127QnVKxlSja5NJVSDZNMCQnPrwKOBfotUugPJYcLZtB-07oTOM87XJ5rlIfmpGP5ejnj7XRdokaMY84xg3RorDCOK6GRNwwFl4wYGTVUQjTaWukMEVokjrp2Q6VRDG1DLUm53xRpJpvI9TOa_Ikr0K-4UJ7zPtIyxRTuLx9ofMDkwx2ef_5LfTw:1t41LG:d1KicukFek0ySBDrCRwRsULYVu7mzE0lupJqrIWhHxM','2024-11-07 17:09:46.982853');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('i2p1igadmiack9dziym1g8ime7y9ni0f','.eJxVkMFuhCAURX-lYW0MiDPA7Npu-wdNQx74GMmgNIJNJsZ_L1q7cEfuO_fwYCEpWg8BrI3zmHXKkDGR27JW5D-DOfc4Zm8h-zjqAXMfu8J8LuTvTG5nCyndTG5MNEoKpiSvL4xdKWsq8j3FH9_hVCr3GO8BCzv7zcAKLhiXigtFKRXswjgj61dF9gX0nHDSO9mSU2bAPnDcBhDCFtfHGvXOHONUv56e8Xa0TqoeUl88wkplJKMSDXdUOUmtk-bKheOsMa2QjgPwrpOqbansUHKBaKERwJ0C54o0YUCbsdMBTPmJc6BHGLDc897j4FOeni8fYOIEOU5Psv4CwgiGSw:1t4Mj5:KAf_p2hkCE8D9sx1TMDiMg7FhVm7HLO8xk0QvinEDZ4','2024-11-08 15:59:47.077482');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('9x66cd9abg12ed0jzx4y1bdfkv1l62t6','.eJxVkL1uhTAMhV-lyowQJEAStnbu0rmqIpOYC7qBVCR0Qbx7DaUDm3X8neOfjcVgR_BgbVjnZGKChJG1256xfw3WNOCcRgtpDLOZMA3BEfO5sb-atfcURt7E2lJyrUsupc6rQhS1zNj3En5Ghws5HiE8PBK6jkdAWTSSc12LQldC11yXSgm2f2XsnG_WiIs5ScFuWgf2ifPRAO8POb-2yE_masf89XbF2-W6RQ0QB8qpsBeq473suETFwTlarmxU1Ut0jatRV31Tqx6kVYVA6ITohSUH1AqIoNCIHm1CZzx09IjmrpgZJqRBHyvMaZ1e3gnafwFk5IKv:1t4dsL:ic_hBTq366zUPVuZBlRzMzQ5ygkpmuAyAxV1Fy33PUE','2024-11-09 10:18:29.515217');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('nqukj44g25l5mzzdzwpqoge6adesv5i0','.eJwlycEKAiEQANB_mfMS7USW3qJrdaouETLoFJapqLsX8d8LetfXoETjyJMxcQpVl0qVC6gGr7Ogz5z2B2lPu-PlCurWIOVouPwefHy6AANYqgQqTN4PkN6GtYmW9czZPRzn__Rh3KyWiALluFiLLaLEe-9fs7Uptg:1t5qtf:-H7mKWibKkMmhRub-UKoaAQoszksxp-3A2Gshxj0Yxk','2024-11-12 18:24:51.569230');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('w2x6ztl9v8xr8j2o5o2lu4e12cvdjf45','.eJytVO9zojoU_Vd2-Vw1_BJw5s08nq22-litrW11Z4cJIWAUCJsEFHf8319A3HY7nZ398L5xz7mce3Nzbn4onCICE4gQLTLhcwEF5srgx-nqPdNECY1JJmmlhetPEiqDrEiSK6XgmPmvYc5oSULMlIESUxonWJEpNa2oABimbuqaY1impRu2Y2iGZBPIhd_WOGuEsh9_S0mGf8rig2DQlwRsqnPZrrIRIueDXq9ti3fPBbuIplIWHvOmqA0s29H7ummDjokdosaMwm0KtkY_yTUe68ix-sDe6poNujDPLzL1uRDNBM7ERbEI_2dFXgS_GQxOIUkkLyASBMEkogxh0_47rvFWocnxS8xIROppCVZg2anwN5Bv5L_LqWb7d1aA9365Nq5H1jX20b38MYMplvwUE7H5tKwkkhMkCobfDDbZ6B-33oM9dxjbFE3YdD7ZatUGr20tyFYrD6rfO85eC7-gcMHig340zeUR-v4sXZkvePUXd_odJKvFpMSZ_7YLCUYwJUl1QZuuCJR-Uy0daJqlq2rthLwFdOCo6ul0tmBtixxyvqesvqXPPOprCxrqWeKZD1q2FtYDiNLHkXiaje-948x0Zzc3Qep9aMB3no4I46Jtqs1_jerc1-hP7izHjNMMJm8qfOB4wv0Q1yql5CQawYTjBpb7GkW_AIWUPA-hAes9rne6mQmjCDfrcj5hUwv-3NYdkn6gIb5YiF2YTG6c_KmnnC4mg2HIpFL9Unz9zQPwJxN479eckRSy6hyevl0pgu5w9us7IxepqSItcHmeXsk2X6mg5nQhcPH1MFkPd9XI4fthkA7nDK5AenS4xzwcG-UhWt-udC9Lrndgl4-Ak-3g8a74vrdm-9W03I29vaOS_nH8ZBsBK3XeOeJKI1_ELqjMyThwaDTJp8wzb-82j9XBnLx40XphuQg_sWBJJv7c-OdfI-ggUW49gnQw973yOU1BsFyui5u-C4fxauqulw_u4uZhdH87ftE84i4OaX7L3OdNie_hc5-6c-PJBWrfUdoj-hwjhkXrtUNO5I349YYoGtCMjgo6mvOoOgNDHZhq19TVtXI6nf4DZGf2kQ:1t5rA8:SlHOHVkER6XDfTECEywMU1v1acONZ3zdZPPxA6AvePk','2024-11-12 18:41:52.543209');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('c9a3qsyt6fsyh9esfnf0fbwr3gzsxif4','.eJxVjMEKwyAQRP9lz6GsxrrBXykliJFESN2SrL2I_15L6aGXYRjemwonh-R3HwKXLPMpXuIJrrYBfpsvssUsKXhJnOdHlI2XztwqfDu4_xforoBTNKImY1Bd9KSRxnGA58GvtMSjKyvzusfOlvR5UDghWdPDKCKDFulqod3bG5IuNK8:1t63Pd:PcwT9PG5KZw1kCboCrY5S5HV8hryS-qz-tXW4XG5iKE','2024-11-13 07:46:41.283980');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('fzfy70wvjq78mmcwpd8y0e2wf861f2i1','eyJzb2NpYWxhY2NvdW50X3N0YXRlcyI6e319:1t8NRB:e3X9BZwBDMbDpkan0IPyy7X9yZGOdRCzmcNTIJKAruU','2024-11-19 17:33:53.872679');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('kpmqaki5d5y42rqs48qpj33of34racc6','.eJxVkMFuhSAQRX-lYW0MCALv7dpu-wdNQ0YcnqQojWCTxvjvRWsXbgi5c-6dCytJ0XoIYG1cpmxShoyJ3NetIv8aLHnAKXsL2cfJjJiH2BfmfSV_d3K_ppDizeTOFKc3qnmrak6loLKtyNccv32Pc7E8YnwELOzi9wRGNVVSlEMwpQpNVSvJ9lGRo4BZEs7mIBty0TqwnzjtAwhhl-uzRn0w5zjVz5dnvJyuS9QAaSg5nXRCska7RradQs150wpJtdalmLZ4c4xaCR132nEQygpkoGRPnROaS1ZCEwa0GXsToCs_cRXMBCOWPa8Djj7l-efprVDbL7WEge8:1t8iKm:Ng0wtH36nOkWsG9Y5cZb-2QDPgh4FPwB3tl4Moikzsw','2024-11-20 15:52:40.177142');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('pi5600uckhrru37pjx0mrbcauf62y7bc','.eJxVj8tqwzAQRf9l1saVrKeza3cldFFaWmgpRpalWESxgiWHQvC_V3aThTdCzJ05c-YKMWinvNI6TENqYlLJRNhd4eXj63NP355fa79_r08X2H1f4TwGbWLOwYeDG6CATiUFu2HyvoDzUZtGh840FzM668x4Twbzm_LQA8wFFgRXmDHCSlHVvOLiZy7gvl9NqTdDclolF4bmZFIfurju_v9nysY4K6iMvlNZXRJeI8lFscheXLdIwCGEgze5d3ILASOJBKf5oVgIijgSjMP8U8Aq0EzRjM3aWcGm1ip9NMMSKO-XcnnTKNeeWxzLx80ZT7epDapXsc-cllvKcSVtxVkrjCSkYpQjKWUWk9rUFiPNVUustERRoanBSvAOWUsl4RjmPxWskS4:1tA0Fb:8D69QXWMCqRpVXsxaCivpMt7eQcY4KLw2Qbj-XljORs','2024-11-24 05:12:39.425071');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('kkvvm3tjjdqjud4aauk6yksjh39qct6z','.eJxdjDsOwjAQBa-CUiPLduxgU0ILZ7B21xsSyEeKnQIh7k4ipQDaN_PmVQSYcxPmxFNoY3EstNTGea2L_TdCoAcPK493GG6joHHIU4tiVcRGk7iOkbvT5v4EGkjN8lbsFZAj0kxGOqlKj6qSBi1wdVAVYrTswUgla--MrBkVO0MGbCyJ7RJN3DFljqEDXIt_Uxig52U_N9y3KU_P3WXx3h9Jv0wq:1tAD0F:0GaTMGNhAQy7iaik2gOWrVkPB5HpWgdwOlkIKVVA0Bg','2024-11-24 18:49:39.053109');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('cjyrsmmjg4chrcedkn6zv8qpktzh25az','.eJyVzTEKgzAUANC7_DmIpokaV3FSOhR0KSIhphINiZooLeLdW-jWrfMb3gHOCsU1F8JuxnfOcy8dZAc0-1Sl9WusbngsaMggux8wr1ZI93FwajDbDAh67jlkZtMawTwJ2Qnby26Xq3oouX7lRFFyiUjIMA0DxihLcdwiqJKGT_m1eJZ5SWqx_BTaDsr8P9AA4yQiMWnP8w3kgEjX:1tAodj:B7fJ3VvpE0yUxEdKxjZ0EdAIL9aiqhsH6lW4men51Ns','2024-11-26 11:00:55.227146');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('cklunszu5btgkc5yl1x5laaza8mdow01','.eJxdj8FuhSAURH-lYW0MCAJ9u7bb_kHTkCtenqQojWCTxvjvRWsXdkPI3JmTmZWkaD0EsDYuUzYpQ8ZEbutWkT8NljzglL2F7ONkRsxD7IvnbSW_f3K7UkjJZnJjijPRtILTWkvGuOYV-Zzjl-9xLpF7jPeAxbv4ncCopkqK8gimlKCSqlaS7b0iRwGzJJzN4WzIRevAfuC0HyCEXa7PGvXhOc-pfrrMeD5TF9QAaSicTjohWaNdI9tOoea8rJBUa12KaYuPjlEroeNOOw5CWYEMlOypc0JzyQo0YUCbsTcBun3cP8lMMGLRXwYcfcrz98Nr8W0_oQ6CLA:1tAtiU:U1ImLe4MJUMz_1FBzTIuVVVcQKx7sCHj0ZNtrHWKmpY','2024-11-26 16:26:10.383305');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('ojdq8mdfq2h29fay9hogyme7zup61ti2','.eJxdj0FuhDAMRa9SZY1QQoKTYdd22xtUFTLBGdAAqUioVCHu3kDpgm4s6_n_b3tlwdseB7TWL1OsQ8RIgVXrlrE_hkvsaIq9xdj7qR4pdr5NmveV_fasuqaw5I2sElqK8gagdF6qkoPM2Ofsv_qW5uS4e38fKEmXfg8Q3HANKhUltFYcuC6BbR8ZO_bXS6C5PpQFu7AG7YOmfYDDsOP8vCI_NOc45M-XL15O1yWqw9ClnAacAlEYV0DZaDJSFqUCboxJhxlLNye4BWykM06i0laRQA0td04ZCSKFBhrIRmrrAZv9uX-onnCkxF87GvsQ5--nt6TbfgBTMYII:1tBbOx:WoV2q6k8rKWSs-24gfS_ShUmpNY_QmCSWylNzEgpTV4','2024-11-28 15:04:55.274406');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('mfrszl1c39rr9cx9aa605di3xrai26dg','.eJxdj8tuhDAMRX-lynqEyIPEmV3bbf-gqpAJzoAGSEVCpQrx7w10uqA76_jcK3tlMbgeB3QuLFOqY8JEkV3X7cL-GC6poyn1DlMfpnqk1IU2O-8r-53Z9dzCcjaxKzeSg1IGqkIJaw3wC_ucw1ff0pwjtxBuA2V36fcGXmojhK1kaZW0lbAcQLLt48KOA-ol0lwfpmQn1qC707QvcBh2XDzOKA7nsY7F8-mNl0fqVNVh7HJPo73SXIAXumoMgZSiUroEAGMUOLKel05jIz14ico4RRyNbkvvFUjNc2mkgVyith6w2Z_7h-oJR8r8taOxj2n-fnrL3vYDyeiCUQ:1tCdwR:JtkHztldhwSNY_zw3vAkQ8NylOUs5WxIwPPqiPkHB3M','2024-12-01 11:59:47.816933');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('pyospfrjoifihhjsmqg1akk8s1irc2t7','.eJxdjcsOgjAQRX_FdG2a6UBt65K1fkMz7RRBkSY8FsT470LCQl2fc899CU_z1Ph5TINvWZwFApZKoRbHbxQoPlK_cb5Tf8sy5n4a2iA3Re50lNfMqat29yfQ0Nisa3JsIGwfDiE4YoOnQhkCAxzAFlgY6zRzsBFrg7YkpaFAbWxpazSwRsfUpTgl9h2FtehAbTntdPkHfU_PtBpVm7t8Ww4XCnmgKQ-LeH8A7ENOgA:1tCgXZ:ibUUG1kdVj0Kz0tfyfRpkonXeOsrNITsjouBEU9g7zU','2024-12-01 14:46:17.566675');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('f6cyxgrbodbovqtdh8yisabaecb69u24','.eJxdkU9PhDAQxb-K6Zkl_d_CTb0Zbx6NIUMpC7FQQ4uJ2fDdbVk0rpem-c17rzPTCwrejODAGL_OsQkRog2ovmwF-mGwxsHOcTQQRz83k42D75Lm9YKud1TfpqDkjagmipGKV0LostKCaqkK9LH4z7GzS7KcvT87m7TrmBMI1lhJng5OlOJYYiUk2t4KtDfQrMEuza6k6Ia1YN7tnAvgXMbl0Ua5a45yKO9vxng4XDdRA4Qh5bSy55JQ3VMpWmU1Y1RwibXWqTFtbNUTbCS0rNc9A64MtwSU7HDfc80kSaHBOmui7RoHbR7uH2pmmGzij4OdxhCXr7vnpCvQYlMbn9c9dxAhfURm-9zz6lxSeD9d11BhSjHlSimGDn6kvjxxTP--mKIyz_ITIScqcjHCEps47g7Ca5IdaSO_SNSEoW37BqvArr8:1tD87S:OSarznF1fQgW5vjcHAyjtKtbBchIS2WX2Y-2sMIqKcE','2024-12-02 20:13:10.335011');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('oeo6ieyv0cpa0s76bnnrogj4kf3p03ai','.eJxdj8FqhTAQRX-lZC2SaEzmuWu77R-UImOcPOVFU0wsFPHfG61d2M0wnLn3cmdlwZsBHRrjlyk2IWKkwOp1y9gfwyX2NMXBYBz81IwUe98lzfvKfndWX1NY8kZWC12Km5ISZA4CNGiVsc_Zfw0dzcly9_7uKGmXYU8QHLhWMg0ptJZccV0ptn1k7CjQLIHm5lAW7MJaNA-a9gM6t-P8rJEfmvMc8ufLGy-n6xLVY-hTTqusVKIAW6iq1QRlWVRScQBIxcDQzQpuFLalBVui1EaSQK06bq2EUokUGsiRidQ1Dtv9uX-omXCkxF97GocQ5--nt6TbfgDF_4JM:1tD954:N-wQ_fUOF60-XVWmhUVCwo0FZdl2pdpTbfbzMv5goHw','2024-12-02 21:14:46.316794');
INSERT INTO "django_session" ("session_key","session_data","expire_date") VALUES ('4ktu2ufweqvtz63p3lhj6mj0hk57wloy','.eJxdjMsOwiAUBX_FsDaER2nBpW71GwgXLrba0qTQhTH-uzRxoW7PzJknsW4tvV0zLnYI5EAEE00jTUv23wicv2PaeLi5dJ2pn1NZBqCbQj8008sccDx-3J9A73Jf3yai8sYAi4Z7L7TmotNdGwDQKTAtaIYiSglaSRWYMoARWiGVD10D3NdoxhF9wWBHB7XI_yab3IR1P_U4Dbksj925eq83X79MVA:1tD9NE:0k4OKgxi1SoZgnzcLKwVupbTKFLYdf6Drav-ZOIiEek','2024-12-02 21:33:32.704227');
INSERT INTO "django_site" ("id","name","domain") VALUES (2,'example.com','example.com');
INSERT INTO "django_site" ("id","name","domain") VALUES (3,'127.0.0.1:8000','127.0.0.1:8000');
INSERT INTO "socialaccount_socialapp_sites" ("id","socialapp_id","site_id") VALUES (1,1,3);
INSERT INTO "socialaccount_socialapp" ("id","provider","name","client_id","secret","key","provider_id","settings") VALUES (1,'google','google','1080789363580-5e9i1groajm0j46lp2sg3c97608j3280.apps.googleusercontent.com','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','','','{}');
INSERT INTO "core_permissions" ("permission_id","codename","name","module_id") VALUES (1,'view_inventory','View Inventory',1);
INSERT INTO "core_permissions" ("permission_id","codename","name","module_id") VALUES (2,'add_new_item','Add New Item',1);
INSERT INTO "core_permissions" ("permission_id","codename","name","module_id") VALUES (3,'update_item_inventory','Update Item''s Inventory (Add, Remove, Report)',1);
INSERT INTO "core_permissions" ("permission_id","codename","name","module_id") VALUES (4,'physical_count','Conduct Physical Count/System Reconcilliation',1);
INSERT INTO "core_permissions" ("permission_id","codename","name","module_id") VALUES (5,'manage_suppliers','Manage Suppliers',1);
INSERT INTO "core_permissions" ("permission_id","codename","name","module_id") VALUES (6,'configure_inventory','Configure Inventory',1);
INSERT INTO "core_permissions" ("permission_id","codename","name","module_id") VALUES (7,'borrow_items','Allow Borrow Items',2);
INSERT INTO "core_permissions" ("permission_id","codename","name","module_id") VALUES (8,'view_borrowed_items','View/Prepare Requested Borrowed Items',2);
INSERT INTO "core_permissions" ("permission_id","codename","name","module_id") VALUES (9,'view_booking_requests','Approve/Deny Booking Requests',2);
INSERT INTO "core_permissions" ("permission_id","codename","name","module_id") VALUES (10,'return_item','Manage Return of Item',2);
INSERT INTO "core_permissions" ("permission_id","codename","name","module_id") VALUES (11,'configure_borrowing','Bonfigure Borrowing',2);
INSERT INTO "core_permissions" ("permission_id","codename","name","module_id") VALUES (12,'view_own_clearance','Check Own Clearance',3);
INSERT INTO "core_permissions" ("permission_id","codename","name","module_id") VALUES (13,'view_student_clearance','Manage User Clearances',3);
INSERT INTO "core_permissions" ("permission_id","codename","name","module_id") VALUES (14,'reserve_laboratory','Reserve Laboratory',4);
INSERT INTO "core_permissions" ("permission_id","codename","name","module_id") VALUES (15,'view_reservations','View Reservations',4);
INSERT INTO "core_permissions" ("permission_id","codename","name","module_id") VALUES (16,'approve_deny_reservations','Approve/Deny Reservation Requests',4);
INSERT INTO "core_permissions" ("permission_id","codename","name","module_id") VALUES (17,'configure_lab_reservation','Configure Lab Reservation',4);
INSERT INTO "core_permissions" ("permission_id","codename","name","module_id") VALUES (18,'view_reports','View/Generate Reports',5);
INSERT INTO "core_permissions" ("permission_id","codename","name","module_id") VALUES (19,'configure_laboratory','Configure Laboratory',6);
INSERT INTO "core_permissions" ("permission_id","codename","name","module_id") VALUES (20,'edit_item_details','Edit Item Details',1);
INSERT INTO "core_permissions" ("permission_id","codename","name","module_id") VALUES (21,'delete_item','Delete Item',1);
INSERT INTO "django_admin_log" ("id","action_time","object_id","object_repr","action_flag","change_message","content_type_id","user_id") VALUES (1,'2024-09-23 07:04:56.082741','3','127.0.0.1:8000',1,'[{"added": {}}]',11,'1');
INSERT INTO "django_admin_log" ("id","action_time","object_id","object_repr","action_flag","change_message","content_type_id","user_id") VALUES (2,'2024-09-23 07:05:39.456059','1','google',1,'[{"added": {}}]',15,'1');
INSERT INTO "django_admin_log" ("id","action_time","object_id","object_repr","action_flag","change_message","content_type_id","user_id") VALUES (3,'2024-09-23 11:15:12.986274','1','Beaker',1,'[{"added": {}}]',17,'1');
INSERT INTO "django_admin_log" ("id","action_time","object_id","object_repr","action_flag","change_message","content_type_id","user_id") VALUES (4,'2024-09-23 11:20:59.453173','1','Inventory Item 1',1,'[{"added": {}}]',19,'1');
INSERT INTO "django_admin_log" ("id","action_time","object_id","object_repr","action_flag","change_message","content_type_id","user_id") VALUES (5,'2024-11-12 10:56:54.452693','1','google',2,'[]',15,'1');
INSERT INTO "account_emailaddress" ("id","email","verified","primary","user_id") VALUES (1,'kenneth_uy@dlsu.edu.ph',1,1,'2');
INSERT INTO "account_emailaddress" ("id","email","verified","primary","user_id") VALUES (2,'luis_ostia@dlsu.edu.ph',1,1,'3');
INSERT INTO "account_emailaddress" ("id","email","verified","primary","user_id") VALUES (3,'dominique_conde@dlsu.edu.ph',1,1,'4');
INSERT INTO "account_emailaddress" ("id","email","verified","primary","user_id") VALUES (4,'system.admin@dlsu.edu.ph',0,0,'1');
INSERT INTO "socialaccount_socialaccount" ("id","provider","uid","last_login","date_joined","extra_data","user_id") VALUES (1,'google','108076480741774060756','2024-11-18 21:14:44.799352','2024-09-23 07:06:40.982688','{"iss": "https://accounts.google.com", "azp": "1080789363580-5e9i1groajm0j46lp2sg3c97608j3280.apps.googleusercontent.com", "aud": "1080789363580-5e9i1groajm0j46lp2sg3c97608j3280.apps.googleusercontent.com", "sub": "108076480741774060756", "hd": "dlsu.edu.ph", "email": "kenneth_uy@dlsu.edu.ph", "email_verified": true, "at_hash": "3IfQrmBHmMsz8PJEuwpBjA", "name": "Kenneth Myrond Uy", "picture": "https://lh3.googleusercontent.com/a/ACg8ocIqsjcJjZ8asgH6ls-my2iWM-qJgV_5xEx1026WTXGq7DZJBw=s96-c", "given_name": "Kenneth Myrond", "family_name": "Uy", "iat": 1731964485, "exp": 1731968085}','2');
INSERT INTO "socialaccount_socialaccount" ("id","provider","uid","last_login","date_joined","extra_data","user_id") VALUES (2,'google','106722953094395291883','2024-11-17 11:59:45.417013','2024-09-23 11:10:21.663319','{"iss": "https://accounts.google.com", "azp": "1080789363580-5e9i1groajm0j46lp2sg3c97608j3280.apps.googleusercontent.com", "aud": "1080789363580-5e9i1groajm0j46lp2sg3c97608j3280.apps.googleusercontent.com", "sub": "106722953094395291883", "hd": "dlsu.edu.ph", "email": "luis_ostia@dlsu.edu.ph", "email_verified": true, "at_hash": "a5w36tBeQBjC-vuvmo4jsA", "name": "Luis Ostia", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJ5K8PX2QNOEHdKMok2YDYsrUbyFmnJHcDhVlj3hLmK3KNcPng=s96-c", "given_name": "Luis", "family_name": "Ostia", "iat": 1731844787, "exp": 1731848387}','3');
INSERT INTO "socialaccount_socialaccount" ("id","provider","uid","last_login","date_joined","extra_data","user_id") VALUES (3,'google','117271389379000715131','2024-10-25 15:59:43.503650','2024-10-06 16:22:08.156090','{"iss": "https://accounts.google.com", "azp": "1080789363580-5e9i1groajm0j46lp2sg3c97608j3280.apps.googleusercontent.com", "aud": "1080789363580-5e9i1groajm0j46lp2sg3c97608j3280.apps.googleusercontent.com", "sub": "117271389379000715131", "hd": "dlsu.edu.ph", "email": "dominique_conde@dlsu.edu.ph", "email_verified": true, "at_hash": "gvCDKBxXQkLiYXwIMjHrNQ", "name": "Dominique Conde", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKlbCzviOVp4YtOXXnaU67ErdqIWBG-0f_NhJ1RHCDuoq3NsSg=s96-c", "given_name": "Dominique", "family_name": "Conde", "iat": 1729872019, "exp": 1729875619}','4');
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (19,2,2,NULL,'19','2',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (20,2,2,NULL,'19','3',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (21,3,1,NULL,'20120241870','14',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (22,5,5,NULL,'20120243677','11',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (23,5,5,NULL,'20120243677','14',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (24,10,10,NULL,'20120240508','2',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (25,1,1,NULL,'20120249262','15',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (26,1,0,NULL,'20120249134','11',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (27,2,0,NULL,'20120249134','14',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (28,1,0,NULL,'20120249134','15',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (29,1,1,NULL,'20120243112','11',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (30,1,1,NULL,'20120243112','14',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (31,1,0,NULL,'20120243112','15',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (32,2,2,NULL,'20120241793','11',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (33,1,1,NULL,'20120241793','15',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (34,1,0,NULL,'20120248237','11',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (35,2,0,NULL,'20120247566','11',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (36,3,0,NULL,'20120247566','14',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (37,5,0,NULL,'20120241713','11',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (38,2,0,NULL,'20120242159','2',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (39,1,0,NULL,'20120242472','14',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (40,1,0,NULL,'20120242565','11',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (41,2,0,NULL,'20120249113','11',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (42,1,0,NULL,'20120249113','15',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (43,1,0,NULL,'20120240933','11',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (44,1,0,NULL,'20120240933','15',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (45,2,0,NULL,'20120245783','11',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (46,4,0,NULL,'20120249997','14',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (47,3,2,NULL,'20120240651','14',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (48,5,0,NULL,'20120249838','10120241077',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (49,1,0,NULL,'20120249838','10120247714',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (50,1,0,NULL,'20120240871','10120241077',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (51,1,0,NULL,'20120240871','10120247714',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (52,1,0,NULL,'20120240696','10120241077',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (53,1,0,NULL,'20120240696','10120247714',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (54,1,0,NULL,'20120248081','10120241077',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (55,1,0,NULL,'20120244782','10120241077',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (56,1,0,NULL,'20120244782','10120247714',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (57,3,0,NULL,'20120240446','10120247714',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (58,5,0,NULL,'20120245905','10120241077',NULL);
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (59,10,0,NULL,'20120247666','11','mL');
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (60,5,0,NULL,'20120241609','10120241077','mL');
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (61,10,0,NULL,'20120241609','11','mL');
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (62,2,0,NULL,'20120241609','16','pcs');
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (63,4,4,NULL,'20120246370','10120241077','mL');
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (64,1,1,NULL,'20120246370','16','pcs');
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (65,1,0,NULL,'20120241462','10120241077','mL');
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (66,1,0,NULL,'20120241462','16','pcs');
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (67,4,0,NULL,'20120246582','10120241077','mL');
INSERT INTO "core_borrowed_items" ("id","qty","returned_qty","remarks","borrow_id","item_id","unit") VALUES (68,1,0,NULL,'20120246582','16','pcs');
INSERT INTO "core_laboratory" ("name","description","department","is_available","date_created","modules","laboratory_id") VALUES (NULL,NULL,NULL,0,'1900-12-30 00:00:00','[]','0');
INSERT INTO "core_laboratory" ("name","description","department","is_available","date_created","modules","laboratory_id") VALUES ('Chemistry Lab','Chem Lab','COB',1,'2024-10-26 06:07:51.948381','[1, 2, 3, 4, 5, 6]','1');
INSERT INTO "core_laboratory" ("name","description","department","is_available","date_created","modules","laboratory_id") VALUES ('Physics Laboratory','PhyLab','COS',0,'2024-10-26 06:07:51.948381','[1, 2, 3, 4, 5, 6]','2');
INSERT INTO "core_laboratory" ("name","description","department","is_available","date_created","modules","laboratory_id") VALUES ('Computer Laboratory','Comp Lab',NULL,0,'2024-10-26 06:07:51.948381','[1]','3');
INSERT INTO "core_laboratory" ("name","description","department","is_available","date_created","modules","laboratory_id") VALUES ('General Lab','Gen Lab','GEN',0,'2024-10-26 06:07:51.948381','[1, 2, 3]','4');
INSERT INTO "core_laboratory" ("name","description","department","is_available","date_created","modules","laboratory_id") VALUES ('Arts Lab','College of Liberal Arts','CLA',0,'2024-10-26 06:07:51.948381','[]','13');
INSERT INTO "core_laboratory" ("name","description","department","is_available","date_created","modules","laboratory_id") VALUES ('Engineering Lab','Engineering Laboratories ','GCOE',0,'2024-10-26 06:17:33.115529','[]','14');
INSERT INTO "core_laboratory" ("name","description","department","is_available","date_created","modules","laboratory_id") VALUES ('Physics Laboratory','Physs Lab','COS',0,'2024-10-26 06:57:48.618690','[]','15');
INSERT INTO "core_laboratory" ("name","description","department","is_available","date_created","modules","laboratory_id") VALUES ('Quantum Lab','QT','QTL',0,'2024-10-26 07:02:18.710881','[]','16');
INSERT INTO "core_laboratory" ("name","description","department","is_available","date_created","modules","laboratory_id") VALUES ('Sample Lab','sample test lab','test',0,'2024-10-29 15:53:14.422937','[]','17');
INSERT INTO "core_laboratory" ("name","description","department","is_available","date_created","modules","laboratory_id") VALUES ('Computer Technology Lab','ct lab ccs','ccs',0,'2024-10-29 15:59:55.727414','[]','18');
INSERT INTO "core_laboratory" ("name","description","department","is_available","date_created","modules","laboratory_id") VALUES ('Psychology Lab','psych','CLA',0,'2024-10-29 17:20:32.986858','[1, 2, 3]','19');
INSERT INTO "core_laboratory" ("name","description","department","is_available","date_created","modules","laboratory_id") VALUES ('Speech Laboratory','test lab permissions','CLA',0,'2024-10-30 16:53:32.384072','[1]','30');
INSERT INTO "core_laboratory" ("name","description","department","is_available","date_created","modules","laboratory_id") VALUES ('Speech Laboratory','test lab permissions','CLA',0,'2024-10-30 16:54:46.642047','[1]','31');
INSERT INTO "core_laboratory" ("name","description","department","is_available","date_created","modules","laboratory_id") VALUES ('Math Laboratory','test lab permissions','COS',0,'2024-10-31 18:58:35.214119','[1]','32');
INSERT INTO "core_laboratory" ("name","description","department","is_available","date_created","modules","laboratory_id") VALUES ('Instrumentation Laboratory','test default permissions','COS',0,'2024-11-04 12:12:05.705988','[1, 2, 3, 4, 5]','34');
INSERT INTO "core_laboratory" ("name","description","department","is_available","date_created","modules","laboratory_id") VALUES ('test create lab','test create lab','test create lab',0,'2024-11-06 12:25:05.760686','[1, 2, 3, 4, 5, 6]','35');
INSERT INTO "core_laboratory" ("name","description","department","is_available","date_created","modules","laboratory_id") VALUES ('test lab','dec','ccs',0,'2024-11-07 08:38:48.382204','[1, 2, 3, 4]','36');
INSERT INTO "core_laboratory" ("name","description","department","is_available","date_created","modules","laboratory_id") VALUES ('ECE Laboratory','electronic engineering laboratory ','GCOE',1,'2024-11-15 08:57:30.918719','[1, 2, 4, 5, 6]','90120243485');
INSERT INTO "core_laboratory" ("name","description","department","is_available","date_created","modules","laboratory_id") VALUES ('Computer Laboratory','Computer science and programming','CCS',1,'2024-11-16 10:59:42.134644','[1, 2, 3, 4]','90120242184');
INSERT INTO "core_laboratory" ("name","description","department","is_available","date_created","modules","laboratory_id") VALUES ('Biology Laboratory','Laboratory for Biology ','COS',1,'2024-11-17 14:44:36.760284','[1, 2, 3, 4, 5, 6]','90120245954');
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (27,9,'1',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (28,11,'1',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (29,8,'1',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (30,10,'1',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (31,7,'1',5);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (38,1,'1',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (39,5,'1',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (40,6,'1',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (41,13,'1',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (42,1,'1',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (43,2,'1',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (44,3,'1',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (45,4,'1',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (46,13,'1',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (47,1,'1',4);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (48,12,'1',5);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (58,18,'1',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (60,18,'1',4);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (123,19,'1',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (229,6,'1',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (359,20,'1',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (360,21,'1',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (382,1,'90120242184',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (383,5,'90120242184',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (384,6,'90120242184',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (385,20,'90120242184',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (386,21,'90120242184',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (387,9,'90120242184',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (388,11,'90120242184',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (389,13,'90120242184',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (390,16,'90120242184',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (391,17,'90120242184',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (392,18,'90120242184',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (393,19,'90120242184',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (394,1,'90120242184',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (395,2,'90120242184',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (396,3,'90120242184',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (397,4,'90120242184',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (398,8,'90120242184',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (399,10,'90120242184',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (400,13,'90120242184',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (401,15,'90120242184',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (402,1,'90120242184',4);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (403,18,'90120242184',4);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (404,7,'90120242184',5);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (405,12,'90120242184',5);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (406,14,'90120242184',5);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (422,7,'1',11);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (423,12,'1',11);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (424,14,'1',11);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (446,1,'90120245954',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (447,5,'90120245954',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (448,6,'90120245954',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (449,20,'90120245954',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (450,21,'90120245954',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (451,9,'90120245954',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (452,11,'90120245954',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (453,13,'90120245954',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (454,16,'90120245954',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (455,17,'90120245954',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (456,18,'90120245954',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (457,19,'90120245954',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (458,1,'90120245954',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (459,2,'90120245954',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (460,3,'90120245954',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (461,4,'90120245954',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (462,8,'90120245954',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (463,10,'90120245954',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (464,13,'90120245954',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (465,15,'90120245954',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (466,1,'90120245954',4);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (467,18,'90120245954',4);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (468,7,'90120245954',5);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (469,12,'90120245954',5);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (470,14,'90120245954',5);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (475,16,'1',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (476,17,'1',2);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (477,15,'1',3);
INSERT INTO "core_laboratory_permissions" ("id","permissions_id","laboratory_id","role_id") VALUES (478,14,'1',5);
INSERT INTO "core_item_types" ("itemType_id","itemType_name","add_cols","is_consumable","laboratory_id") VALUES (1,'Chemicals','["Nature", "Grade", "chemical formula", "synonyms"]',0,'1');
INSERT INTO "core_item_types" ("itemType_id","itemType_name","add_cols","is_consumable","laboratory_id") VALUES (2,'Glasswares','["Nature", "Brand", "Location", "Status", "L or S", "Capacity", "Dimension"]',0,'1');
INSERT INTO "core_item_types" ("itemType_id","itemType_name","add_cols","is_consumable","laboratory_id") VALUES (3,'Equipments','["Grade (A, B, C)"]',0,'1');
INSERT INTO "core_item_types" ("itemType_id","itemType_name","add_cols","is_consumable","laboratory_id") VALUES (4,'Equipments','["Brand"]',0,'2');
INSERT INTO "core_item_types" ("itemType_id","itemType_name","add_cols","is_consumable","laboratory_id") VALUES (8,'Glasswares','[]',0,'2');
INSERT INTO "core_item_types" ("itemType_id","itemType_name","add_cols","is_consumable","laboratory_id") VALUES (12,'Test instrument','["Brand"]',0,'90120243485');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('19','2024-10-25 07:08:13.653478','2024-10-29','2024-10-29','X','{}',NULL,'2','1',NULL);
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120241870','2024-11-08 07:11:58.941415','2024-11-09','2024-11-09','B','{"Faculty to charge": "smaple"}','Accepted',NULL,'1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120243677','2024-11-10 06:27:13.237344','2024-11-01','2024-11-14','X','{"Faculty to charge": "smaple"}',NULL,'2','1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120240508','2024-11-10 06:33:22.252705','2024-11-13','2024-11-13','X','{"Faculty to charge": "smaple"}',NULL,'2','1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120249262','2024-11-10 18:50:19.560045','2024-11-13','2024-11-13','X','{"Faculty to charge": "CHEM"}',NULL,'20248922','1','20248922');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120249134','2024-11-11 12:52:10.351450','2024-11-21','2024-11-21','D','{"Faculty to charge": "smaple"}',NULL,'2','1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120243112','2024-11-11 13:31:35.211659','2024-11-14','2024-11-14','B','{"Faculty to charge": "testing on hold"}',NULL,'2','1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120241793','2024-11-14 07:22:36.188645','2024-11-10','2024-11-18','X','{"Thesis or not": null}','did not get the items',NULL,'1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120248237','2024-11-15 01:17:32.840836','2024-11-17','2024-11-17','B','{"Thesis or not": "yes"}','Accepted',NULL,'1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120247566','2024-11-15 01:52:44.865540','2024-11-29','2024-11-29','B','{"Thesis or not": "yes"}','Accepted',NULL,'1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120241713','2024-11-15 02:27:40.915013','2024-11-27','2024-11-27','A','{"Thesis or not": "yes"}','Accepted',NULL,'1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120242159','2024-11-15 02:34:55.277472','2024-11-20','2024-11-20','A','{"Thesis or not": "yes"}','low qty',NULL,'1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120242472','2024-11-15 07:02:51.191249','2024-11-15','2024-11-15','B','{"Thesis or not": "yes"}',NULL,'2','1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120242565','2024-11-15 07:04:24.710793','2024-11-15','2024-11-15','B','{"Thesis or not": ""}',NULL,'2','1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120249113','2024-11-15 07:05:44.430637','2024-11-15','2024-11-15','L','{"Thesis or not": "no"}','','2','1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120240933','2024-11-15 07:40:42.830833','2024-11-21','2024-11-21','A','{"Thesis or not": "yes"}','low stock','2','1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120245783','2024-11-15 11:19:38.133097','2024-11-27','2024-11-27','A','{"Thesis or not": "yes"}',NULL,'2','1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120249997','2024-11-15 12:04:49.957983','2024-11-15','2024-11-15','B','{"Thesis or not": "yes"}','fhgf',NULL,'1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120240651','2024-11-15 12:46:26.401751','2024-11-15','2024-11-15','B','{"Thesis or not": "yes"}','gdfg',NULL,'1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120249838','2024-11-16 09:12:13.681118','2024-11-19','2024-11-19','A','{"Thesis or not": null}','lo qual','2','1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120240871','2024-11-16 09:25:09.236624','2024-11-28','2024-11-28','A','{"Thesis or not": "yes"}',NULL,'2','1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120240696','2024-11-16 09:25:27.368909','2024-11-26','2024-11-26','D','{"Thesis or not": "yes"}','not allowed','2','1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120248081','2024-11-16 09:31:23.182014','2024-11-29','2024-11-29','A','{"Thesis or not": "yes"}','Accepted','2','1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120241849','2024-11-16 09:49:14.353293','2024-11-16','2024-11-16','B','{"Thesis or not": ""}',NULL,NULL,'1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120244782','2024-11-16 09:50:04.144002','2024-11-16','2024-11-16','B','{"Thesis or not": "yes"}',NULL,NULL,'1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120240446','2024-11-16 09:50:56.912911','2024-11-16','2024-11-16','B','{"Thesis or not": "yes"}','',NULL,'1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120245905','2024-11-16 10:15:21.127043','2024-11-28','2024-11-28','A','{"Thesis or not": null}','low stock','2','1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120247666','2024-11-16 17:11:54.413315','2024-11-22','2024-11-22','A','{"Thesis or not": null}','Accepted','2','1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120241609','2024-11-17 11:16:24.469834','2024-11-22','2024-11-22','A','{"Thesis or not": null}','Accepted','2','1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120246370','2024-11-17 11:16:55.302668','2024-11-17','2024-11-17','X','{"Thesis or not": ""}',NULL,NULL,'1','2');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120241462','2024-11-18 07:34:36.386033','2024-11-22','2024-11-22','P','{"Thesis or not": null}',NULL,NULL,'1','20244396');
INSERT INTO "core_borrow_info" ("borrow_id","request_date","borrow_date","due_date","status","questions_responses","remarks","approved_by_id","laboratory_id","user_id") VALUES ('20120246582','2024-11-18 08:28:41.687074','2024-11-21','2024-11-21','P','{"Thesis or not": "False"}',NULL,NULL,'1','2');
INSERT INTO "core_borrowing_config" ("laboratory_id","allow_walkin","allow_prebook","prebook_lead_time","allow_shortterm","allow_longterm","questions_config") VALUES ('1',1,1,2,1,1,'[{"question_text": "Thesis or not", "input_type": "true_false", "borrowing_mode": "both", "choices": []}]');
INSERT INTO "core_borrowing_config" ("laboratory_id","allow_walkin","allow_prebook","prebook_lead_time","allow_shortterm","allow_longterm","questions_config") VALUES ('90120242184',0,0,1,0,0,'[]');
INSERT INTO "core_borrowing_config" ("laboratory_id","allow_walkin","allow_prebook","prebook_lead_time","allow_shortterm","allow_longterm","questions_config") VALUES ('90120243485',0,0,0,1,1,'[]');
INSERT INTO "core_borrowing_config" ("laboratory_id","allow_walkin","allow_prebook","prebook_lead_time","allow_shortterm","allow_longterm","questions_config") VALUES ('90120245954',0,0,1,0,0,'[]');
INSERT INTO "core_laboratory_roles" ("roles_id","name","laboratory_id") VALUES (2,'Laboratory Coordinator','0');
INSERT INTO "core_laboratory_roles" ("roles_id","name","laboratory_id") VALUES (3,'Laboratory Technician','0');
INSERT INTO "core_laboratory_roles" ("roles_id","name","laboratory_id") VALUES (4,'Department Heads','0');
INSERT INTO "core_laboratory_roles" ("roles_id","name","laboratory_id") VALUES (5,'Student','0');
INSERT INTO "core_laboratory_roles" ("roles_id","name","laboratory_id") VALUES (6,'Faculty','0');
INSERT INTO "core_laboratory_roles" ("roles_id","name","laboratory_id") VALUES (11,'Non DLSU','1');
INSERT INTO "core_reported_items" ("qty_reported","report_reason","amount_to_pay","reported_date","remarks","status","borrow_id","item_id","report_id","laboratory_id","user_id") VALUES (2,'lost',200,'2024-11-10 07:47:19.650552','paid',0,'20120243677','14','30120245331','1','2');
INSERT INTO "core_reported_items" ("qty_reported","report_reason","amount_to_pay","reported_date","remarks","status","borrow_id","item_id","report_id","laboratory_id","user_id") VALUES (2,'lost',200,'2024-10-10 08:28:45.562719',NULL,0,'20120241870','14','30120240140','1','2');
INSERT INTO "core_reported_items" ("qty_reported","report_reason","amount_to_pay","reported_date","remarks","status","borrow_id","item_id","report_id","laboratory_id","user_id") VALUES (2,'BROKEN LCD',200,'2024-11-10 18:49:59.163063',NULL,1,NULL,'15','30120245332','1','20248922');
INSERT INTO "core_reported_items" ("qty_reported","report_reason","amount_to_pay","reported_date","remarks","status","borrow_id","item_id","report_id","laboratory_id","user_id") VALUES (0,'DAMAGE LCD',2000,'2024-11-10 18:50:52.808899',NULL,1,'20120249262','15','30120245333','1','5');
INSERT INTO "core_reported_items" ("qty_reported","report_reason","amount_to_pay","reported_date","remarks","status","borrow_id","item_id","report_id","laboratory_id","user_id") VALUES (1,'broken',2000,'2024-11-14 07:29:45.516567','PAID',0,'20120243112','15','30120245334','1','2');
INSERT INTO "core_reported_items" ("qty_reported","report_reason","amount_to_pay","reported_date","remarks","status","borrow_id","item_id","report_id","laboratory_id","user_id") VALUES (4,'loss',200,'2024-11-14 07:32:44.116915',NULL,0,NULL,'3','30120245335','1','20248922');
INSERT INTO "core_reported_items" ("qty_reported","report_reason","amount_to_pay","reported_date","remarks","status","borrow_id","item_id","report_id","laboratory_id","user_id") VALUES (0,'broken lcd',20000,'2024-11-15 07:45:47.046023',NULL,1,'20120241793','15','30120245336','1','2');
INSERT INTO "core_reported_items" ("qty_reported","report_reason","amount_to_pay","reported_date","remarks","status","borrow_id","item_id","report_id","laboratory_id","user_id") VALUES (1,'broken lost',2000,'2024-11-15 14:15:16.848710',NULL,1,'20120240651','14','30120245337','1','2');
INSERT INTO "core_reported_items" ("qty_reported","report_reason","amount_to_pay","reported_date","remarks","status","borrow_id","item_id","report_id","laboratory_id","user_id") VALUES (0,'broken glass',5000,'2024-11-17 11:17:38.447546','paid cleared',0,'20120246370','16','30120245338','1','2');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (1,'1',3,'13',1,'A','2024-11-12 13:14:30.313484');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (3,'1',2,'11',1,'A','2024-11-12 13:14:30.313484');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (4,'1',2,'2',1,'A','2024-11-12 13:14:30.313484');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (5,'1',4,'19',0,'A','2024-11-12 13:14:30.313484');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (6,'34',2,'20',1,'A','2024-11-12 13:14:30.313484');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (8,'1',6,'5',1,'A','2024-11-12 13:14:30.313484');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (11,'2',5,'2',1,'A','2024-11-12 13:14:30.313484');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (12,'35',2,'2',1,'A','2024-11-12 13:14:30.313484');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (13,'1',2,'3',1,'A','2024-11-12 13:14:30.313484');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (14,'1',11,'9',1,'A','2024-11-12 13:14:30.313484');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (16,'1',2,'20248922',0,'A','2024-11-12 13:14:30.313484');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (17,'1',2,'20',0,'A','2024-11-12 13:14:30.313484');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (18,'36',2,'2',1,'D','2024-11-12 13:27:07.962597');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (19,'36',2,'2',1,'A','2024-11-12 14:25:06.587752');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (20,'15',2,'20245694',1,'A','2024-11-13 12:48:06.041376');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (21,'4',2,'11',1,'A','2024-11-14 06:43:10.221836');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (22,'90120243485',2,'2',1,'A','2024-11-15 08:57:52.858683');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (23,'1',3,'20248922',0,'A','2024-11-17 08:45:29.273392');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (24,'1',4,'19',0,'A','2024-11-17 08:58:31.925512');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (25,'1',4,'19',1,'A','2024-11-17 09:05:08.624009');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (26,'1',2,'20',0,'A','2024-11-17 11:19:51.876286');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (27,'1',2,'20',1,'A','2024-11-17 11:20:18.048293');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (28,'90120245954',2,'20241125',1,'A','2024-11-17 14:45:18.201383');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (29,'90120245954',3,'20248874',1,'A','2024-11-17 14:45:25.488322');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (30,'90120245954',5,'20246982',1,'A','2024-11-17 14:46:08.864146');
INSERT INTO "core_laboratory_users" ("id","laboratory_id","role_id","user_id","is_active","status","timestamp") VALUES (31,'1',5,'20244396',1,'A','2024-11-18 07:24:27.115233');
INSERT INTO "core_reservation_config" ("id","reservation_type","start_time","end_time","require_approval","require_payment","approval_form","leadtime","laboratory_id","tc_description") VALUES (1,'class','07:30:00','19:30:00',0,0,'approval_forms/Chemistry_Lab_inventory_2024-11-08.pdf',1,'1','The terms and conditions below apply for reservations made by an individual, private person unless a special agreement has been made. Separate rules apply for group reservations over 10 persons. The hotel reserves a right to apply special terms and conditions that differ from these in case of public holidays, special events, seasonality or additional services require so.

1. BOOKING AND CONFIRMATION

When reserving a room your name, address, arrival- and departure time and method of payment are required.

A room reservation is binding once it has been confirmed verbally or in writing and you have received a reservation confirmation number. The hotel is entitled to apply different kinds of rules such as reservation fee or credit card guarantee in order to secure the reservation.

2. ARRIVAL AND DEPARTURE

The hotel room is at your disposal from 3:00 pm on the day of arrival. On your departure day the room must be vacated by 12:00 noon. The hotel is entitled to apply exceptions on check-in and check-out times stated above. For safety reasons, only checked-in guests are allowed on private premises and the maximum capacity per room may not be surpassed.

The room will be reserved for you until 4:00 pm on the day of arrival unless no other agreement has been made at the time of reserving or if the confirmed rate or reservation period does not include any other special terms. In case of arrival after 4:00 pm you can guarantee the reservation with a credit card or other method specified. Otherwise the hotel can release the reserved room for sale after 4:00 pm.

In case you arrive to the hotel according to the arrival time agreed and the room you have reserved is not available, the hotel is liable to arrange you an equivalent room without extra charges.

3. GUARANTEED RESERVATION

Credit card guarantee is required for all bookings when confirming the reservation*. Credit card guarantee is required when confirming the reservation. We will send a link in a separate email to securely guarantee the booking. Kindly note that we do not accept credit card details sent by email or over the phone. Customers with an invoicing agreement may guarantee the reservation under company name. As an alternative method of guarantee, Kämp Collection Hotels reserves the right to require either a complete or partial advance payment in order to guarantee the reservation. Amount of prepayment and a schedule for prepayment will be contracted with customer in writing.

*Kämp Collection Hotels reserves the right to verify the credit card to the agreed amount.

4. CANCELLATION AND NO ARRIVAL

Unless otherwise agreed at the time of reservation, unless the rate confirmed or the reservation period includes special terms, the room can be cancelled until 18:00 on the day prior to arrival without a fee.

In case you fail to arrive without cancelling your reservation, the hotel is entitled to charge equal to the first night''s stay including taxes and possible additional services per room to your credit card.

5. EARLY DEPARTURE

Early departure before the agreed day must be informed to the hotel latest by 4:00 pm on the day before.

If your reservation is for several nights the hotel is entitled to charge you the full amount for the whole stay. Early departure before the agreed day may also cause changes in the room rate confirmed.

6. PAYMENT

All hotels accept the most common credit/debit cards. The hotel is not obliged to accept foreign currency, vouchers, cheques or credit/debit cards unless the hotel has volunteered to do so.

In case the reservation has not been paid in advance it should be settled upon arrival at the hotel by cash or credit card. When reserving a room the hotel is entitled to approve and charge international credit cards. A reservation fee may be charged to the credit card as a prepayment. This will be deducted from the final bill. If the hotel has not made an approval for prepayment from your credit card, the hotel is entitled to require a deposit for additional services such as minibar. The amount of deposit may vary among hotels, being the total deposit sum between 50-200€

7. GUEST BEHAVIOUR IN THE HOTEL

We follow good manners and hotel rules at the hotel. In case of breaking these rules you may be immediately removed from the premises. In such cases you are still obliged to pay for the accommodation and additional services ordered. You are not eligible to claim a refund for payments already made.

For safety reasons, only checked-in guests are allowed on private hotel premises such as hotel rooms and the maximum capacity per room may not be surpassed.

8. RESPONSIBILITY ON YOUR VALUABLES

Your valuables can be stored in a safety deposit box in your room or the hotel can store your valuables upon request. The hotel is entitled to collect a charge for storage of these items.

In case the items you wish to store are exceptionally valuable you must notify the hotel before storing. The hotel may refuse to store this kind of valuables.

The hotel is not responsible for valuables stored in a safety deposit box in your room.

The hotel is not responsible for damage or disappearance of vehicles kept in the garage or the hotel’s parking area or valuables inside the vehicle. The hotel is obliged to clearly express in the garage and at the parking area that the area is not supervised and the hotel is not responsible for the property kept in there.

9. GUEST’S RESPONSIBILITY ON DAMAGE

As a guest you are responsible for damage caused on purpose or by accident by you (for example caused from smoking or using electric cigarette), your guest or your pet in the hotel room or in hotel premises. This applies also to the hotel furniture and other equipment, other guests in the hotel or their property.

The responsibility for caused damage is determined by general principles.

10. RENTING HOTEL ROOMS FOR MINORS

Only a person over the age of 18 is allowed to make a reservation. The adult making a reservation for a person under the age of 18 will be held responsible for the minor, whether he or she accommodates with the minor or not. An underage person travelling alone will need a letter of consent signed by a guardian. The letter has to include the minor’s name, birthday and dates of arrival and departure. The name and contact information of a guardian are also required.');
INSERT INTO "core_reservation_config" ("id","reservation_type","start_time","end_time","require_approval","require_payment","approval_form","leadtime","laboratory_id","tc_description") VALUES (4,'class',NULL,NULL,0,0,'',0,'90120242184','');
INSERT INTO "core_reservation_config" ("id","reservation_type","start_time","end_time","require_approval","require_payment","approval_form","leadtime","laboratory_id","tc_description") VALUES (5,'class',NULL,NULL,0,0,'',0,'90120245954','');
INSERT INTO "core_reservation_config" ("id","reservation_type","start_time","end_time","require_approval","require_payment","approval_form","leadtime","laboratory_id","tc_description") VALUES (6,'class',NULL,NULL,0,0,'',0,'90120243485',NULL);
INSERT INTO "core_laboratory_reservations" ("reservation_id","request_date","start_date","start_time","end_time","status","purpose","num_people","contact_email","contact_name","room_id","user_id","filled_approval_form","laboratory_id") VALUES ('22','2024-10-26 05:25:25.046657','2024-10-28','13:25:00','14:25:00','R','THESIS',10,'luis_ostia@dlsu.edu.ph','Luis Ostia','2','3',NULL,'1');
INSERT INTO "core_laboratory_reservations" ("reservation_id","request_date","start_date","start_time","end_time","status","purpose","num_people","contact_email","contact_name","room_id","user_id","filled_approval_form","laboratory_id") VALUES ('23','2024-11-04 12:26:42.720784','2024-11-08','08:00:00','09:30:00','R','thesis',45,'chem_labtech@gmail.com','Kenneth Myrond Domingo Uy','1','13',NULL,'1');
INSERT INTO "core_laboratory_reservations" ("reservation_id","request_date","start_date","start_time","end_time","status","purpose","num_people","contact_email","contact_name","room_id","user_id","filled_approval_form","laboratory_id") VALUES ('24','2024-11-04 12:32:29.361080','2024-11-08','12:00:00','13:32:00','R','thesis',5,'chem_labtech@gmail.com','Kenneth Myrond Domingo Uy','2','13',NULL,'1');
INSERT INTO "core_laboratory_reservations" ("reservation_id","request_date","start_date","start_time","end_time","status","purpose","num_people","contact_email","contact_name","room_id","user_id","filled_approval_form","laboratory_id") VALUES ('40120244801','2024-11-11 17:30:57.299913','2024-11-20','01:33:00','13:35:00','R','thesis',4,'kenneth_uy@dlsu.edu.ph','ken uy','00220248258','2',NULL,'1');
INSERT INTO "core_laboratory_reservations" ("reservation_id","request_date","start_date","start_time","end_time","status","purpose","num_people","contact_email","contact_name","room_id","user_id","filled_approval_form","laboratory_id") VALUES ('40120248580','2024-11-12 16:25:15.752200','2024-11-22','13:13:00','15:13:00','R','test file',45,'kenneth_uy@dlsu.edu.ph','ken uy','00220248258','2','filled_approval_forms/Chemistry_Lab_inventory_2024-11-08.pdf','1');
INSERT INTO "core_laboratory_reservations" ("reservation_id","request_date","start_date","start_time","end_time","status","purpose","num_people","contact_email","contact_name","room_id","user_id","filled_approval_form","laboratory_id") VALUES ('40120244111','2024-11-12 16:26:10.366303','2024-11-15','14:33:00','15:33:00','R','test file',4,'kenneth_uy@dlsu.edu.ph','ken uy','00220248258','2','filled_approval_forms/Chemistry_Lab_inventory_2024-11-08_lDGEPyG.pdf','1');
INSERT INTO "core_laboratory_reservations" ("reservation_id","request_date","start_date","start_time","end_time","status","purpose","num_people","contact_email","contact_name","room_id","user_id","filled_approval_form","laboratory_id") VALUES ('40120241739','2024-11-13 11:34:25.924809','2024-11-20','16:41:00','17:41:00','R','test pre-approval',45,'kenneth_uy@dlsu.edu.ph','ken uy','00220247872','2','filled_approval_forms/Inventory_2hn7TdP.pdf','1');
INSERT INTO "core_laboratory_reservations" ("reservation_id","request_date","start_date","start_time","end_time","status","purpose","num_people","contact_email","contact_name","room_id","user_id","filled_approval_form","laboratory_id") VALUES ('40120240756','2024-11-13 14:13:31.253004',NULL,NULL,NULL,'P','thesis test',56,'kenneth_uy@dlsu.edu.ph','ken uy',NULL,'2','filled_approval_forms/Inventory_ouyPhYM.pdf','1');
INSERT INTO "core_laboratory_reservations" ("reservation_id","request_date","start_date","start_time","end_time","status","purpose","num_people","contact_email","contact_name","room_id","user_id","filled_approval_form","laboratory_id") VALUES ('40120242017','2024-11-15 15:51:41.656474',NULL,NULL,NULL,'P','thesis',5,'kenneth_uy@dlsu.edu.ph','ken uy',NULL,'2','filled_approval_forms/Inventory_rB0GpYX.pdf','1');
INSERT INTO "core_laboratory_reservations" ("reservation_id","request_date","start_date","start_time","end_time","status","purpose","num_people","contact_email","contact_name","room_id","user_id","filled_approval_form","laboratory_id") VALUES ('40120248935','2024-11-18 17:35:12.941281','2024-11-20','09:34:00','10:34:00','R','thesis                ',45,'kenneth_uy@dlsu.edu.ph','ken uy','90220246403','2','','1');
INSERT INTO "core_laboratory_reservations" ("reservation_id","request_date","start_date","start_time","end_time","status","purpose","num_people","contact_email","contact_name","room_id","user_id","filled_approval_form","laboratory_id") VALUES ('40120240198','2024-11-18 18:47:12.286746','2024-11-20','07:35:00','09:35:00','R','exam    ',20,'kenneth_uy@dlsu.edu.ph','ken uy','90220247773','2','','1');
INSERT INTO "core_laboratory_reservations" ("reservation_id","request_date","start_date","start_time","end_time","status","purpose","num_people","contact_email","contact_name","room_id","user_id","filled_approval_form","laboratory_id") VALUES ('40120247341','2024-11-18 21:32:40.727677','2024-11-22','09:31:00','10:32:00','R','thesis experimentation
                ',56,'chem_student@dlsu.edu.ph','Chem Student','90220247773','20244396','','1');
INSERT INTO "core_laboratory_reservations" ("reservation_id","request_date","start_date","start_time","end_time","status","purpose","num_people","contact_email","contact_name","room_id","user_id","filled_approval_form","laboratory_id") VALUES ('40120249316','2024-11-18 21:33:32.687233','2024-11-22','09:00:00','09:30:00','R','use of machine',2,'chem_student@dlsu.edu.ph','Chem Student','90220247773','20244396','','1');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-10-24 18:09:10.589308','2024-10-24 18:09:10.589308',NULL,NULL,0,'2',NULL,'66');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-10-24 18:09:10.630339','2024-10-24 18:09:10.630339',NULL,NULL,0,'3',NULL,'67');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-10-24 18:09:10.669298','2024-10-24 18:09:10.669298',NULL,NULL,0,'5',NULL,'68');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-10-24 18:09:10.706298','2024-10-24 18:09:10.706298',NULL,NULL,9,'6',NULL,'69');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-10-24 18:09:10.749629','2024-10-24 18:09:10.749629',NULL,NULL,8,'7',NULL,'70');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-10-24 18:09:10.793359','2024-10-24 18:09:10.793359',NULL,NULL,10,'11',NULL,'71');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-10-24 18:09:10.842342','2024-10-24 18:09:10.842342',NULL,NULL,10,'14',NULL,'72');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-10-24 18:09:10.893344','2024-10-24 18:09:10.893344',NULL,NULL,10,'15',NULL,'73');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-10-24 18:09:10.945678','2024-10-24 18:09:10.945678',NULL,NULL,10,'16',NULL,'74');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-10-24 18:09:10.992466','2024-10-24 18:09:10.992466',NULL,NULL,10,'17',NULL,'75');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-10-24 18:09:11.046480','2024-10-24 18:09:11.046480',NULL,NULL,10,'18',NULL,'76');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-10-25 02:18:00','2024-10-23 02:18:00',100.0,'add',0,'2','2','77');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-10-25 03:34:00','2024-10-25 03:34:00',100.0,NULL,0,'2','3','78');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-10-25 03:37:00','2024-10-25 03:37:00',100.0,NULL,0,'3','3','79');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-03 19:44:00','2024-11-06 19:44:00',100.0,NULL,18,'10120243849','5','80');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-06 19:46:00','2024-11-06 19:46:00',1000.0,NULL,14,'10120243969','6','81');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-06 19:46:00','2024-11-06 19:46:00',3000.0,NULL,14,'10120240031','6','82');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-06 19:47:00','2024-11-06 19:47:00',3000.0,NULL,40,'10120241950','7','83');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-06 19:47:00','2024-11-06 19:47:00',50000.0,NULL,50,'10120243666','7','84');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-06 19:48:00','2024-11-06 19:48:00',2000.0,NULL,60,'10120247977','6','85');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-06 11:56:37.152531','2024-11-06 11:56:37.152531',NULL,NULL,1,'10120243849',NULL,'86');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-06 11:58:28.235420','2024-11-06 11:58:28.235420',NULL,NULL,1,'10120243969',NULL,'87');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-06 00:00:00','2024-11-06 00:00:00',2000.0,NULL,30,'10120240031','6','88');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-15 00:00:00','2024-11-22 00:00:00',2000.0,NULL,2,'10120242485','2','89');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-08 07:01:30.022952','2024-11-08 07:01:30.022952',NULL,NULL,0,'10120241077',NULL,'90');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-09 00:00:00','2024-11-09 00:00:00',200.0,NULL,5,'2','2','91');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-09 00:00:00','2024-11-09 00:00:00',200.0,NULL,9,'2','2','92');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-09 00:00:00','2024-11-09 00:00:00',200.0,NULL,10,'2','2','93');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-14 00:00:00','2024-11-22 00:00:00',5000.0,NULL,24,'10120247714','3','94');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-19 00:00:00','2024-11-13 00:00:00',30000.0,NULL,30,'10120243969','5','102101202439690001');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-11 00:00:00','2024-11-14 00:00:00',40000.0,NULL,20,'10120243969','6','102101202439690002');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-22 00:00:00','2024-11-22 00:00:00',50000.0,NULL,40,'10120240031','5','102101202400310001');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-12 00:00:00','2024-11-14 00:00:00',5000.0,NULL,10,'2','3','10220001');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-10 00:00:00','2024-11-14 00:00:00',5000.0,NULL,0,'3','2','10230001');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-04 00:00:00','2024-11-14 00:00:00',5000.0,NULL,0,'5','3','10250001');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-10 00:00:00','2024-11-14 00:00:00',4000.0,NULL,0,'5','3','10250002');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-10 00:00:00','2024-11-12 00:00:00',4000.0,NULL,12,'3','4','10230002');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-11 00:00:00','2024-11-29 00:00:00',3000.0,NULL,20,'6','3','10260001');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-11 00:00:00','2024-11-22 00:00:00',4000.0,NULL,20,'7','3','10270001');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-10 00:00:00','2024-11-22 00:00:00',30000.0,NULL,1,'10120248885','3','102101202488850001');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-21 00:00:00','2024-11-20 00:00:00',3000.0,NULL,1,'10120248885','2','102101202488850002');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-04 00:00:00','2024-11-14 00:00:00',3000.0,NULL,30,'2','4','10220002');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-03 00:00:00','2024-11-21 00:00:00',5000.0,NULL,1,'5','4','10250003');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-03 00:00:00','2024-11-21 00:00:00',6000.0,NULL,4,'7','4','10270002');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-04 00:00:00','2024-11-20 00:00:00',4000.0,NULL,2,'7','4','10270003');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-21 00:00:00','2024-11-29 00:00:00',2000.0,NULL,0,'10120246316','10220247939','102101202463160001');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-11 00:00:00','2024-11-29 00:00:00',2000.0,NULL,1,'10120246316','10220247939','102101202463160002');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-04 00:00:00','2024-11-22 00:00:00',3000.0,NULL,1,'10120248163','3','102101202481630001');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-17 07:43:24.902674','2024-11-17 07:43:24.902674',NULL,NULL,0,'10120241077',NULL,'102101202410770001');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-17 07:54:31.868024','2024-11-17 07:54:31.868024',NULL,NULL,7,'10120241077',NULL,'102101202410770002');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-11 00:00:00','2024-11-21 00:00:00',30000.0,NULL,1,'10120241939','10220246857','102101202419390001');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-11 00:00:00','2024-11-21 00:00:00',5000.0,NULL,3,'10120244169','3','102101202441690001');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-11 00:00:00','2024-11-15 00:00:00',5000.0,NULL,5,'10120246239','3','102101202462390001');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-12 00:00:00','2024-11-22 00:00:00',6000.0,NULL,10,'10120242377','4','102101202423770001');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-04 00:00:00','2024-11-22 00:00:00',5000.0,NULL,10,'10120248037','3','102101202480370001');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-05 00:00:00','2024-11-22 00:00:00',1000.0,NULL,20,'10120246711','4','102101202467110001');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-14 00:00:00','2024-11-23 00:00:00',2000.0,NULL,20,'10120243607','4','102101202436070001');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-06 00:00:00','2024-11-23 00:00:00',2000.0,NULL,1,'10120243607','2','102101202436070002');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-10 00:00:00','2024-11-20 00:00:00',2000.0,NULL,1,'10120243607','4','102101202436070003');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-04 00:00:00','2024-11-21 00:00:00',3000.0,NULL,1,'10120243607','4','102101202436070004');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES (NULL,NULL,0.0,NULL,0,'5',NULL,'10250004');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES (NULL,NULL,0.0,NULL,0,'5',NULL,'10250005');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES (NULL,NULL,0.0,NULL,3,'3',NULL,'10230003');
INSERT INTO "core_item_inventory" ("date_purchased","date_received","purchase_price","remarks","qty","item_id","supplier_id","inventory_item_id") VALUES ('2024-11-14 00:00:00','2024-11-21 00:00:00',4000.0,NULL,1,'5','4','10250006');
INSERT INTO "core_item_expirations" ("expired_date","inventory_item_id") VALUES ('2024-10-30','77');
INSERT INTO "core_item_expirations" ("expired_date","inventory_item_id") VALUES ('2024-10-26','78');
INSERT INTO "core_item_expirations" ("expired_date","inventory_item_id") VALUES ('2024-10-25','79');
INSERT INTO "core_item_expirations" ("expired_date","inventory_item_id") VALUES ('2024-11-23','91');
INSERT INTO "core_item_expirations" ("expired_date","inventory_item_id") VALUES ('2024-11-23','93');
INSERT INTO "core_item_expirations" ("expired_date","inventory_item_id") VALUES ('2024-12-21','94');
INSERT INTO "core_item_expirations" ("expired_date","inventory_item_id") VALUES ('2024-11-14','10220001');
INSERT INTO "core_item_expirations" ("expired_date","inventory_item_id") VALUES ('2024-11-28','10230001');
INSERT INTO "core_item_expirations" ("expired_date","inventory_item_id") VALUES ('2024-11-27','10220002');
INSERT INTO "core_item_expirations" ("expired_date","inventory_item_id") VALUES ('2024-11-26','102101202462390001');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (85,'2024-10-24 18:09:10.602327','A',10,'Physical count adjustment','66','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (86,'2024-10-24 18:09:10.643297','A',10,'Physical count adjustment','67','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (87,'2024-10-24 18:09:10.681298','A',10,'Physical count adjustment','68','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (88,'2024-10-24 18:09:10.718949','A',10,'Physical count adjustment','69','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (89,'2024-10-24 18:09:10.763631','A',10,'Physical count adjustment','70','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (90,'2024-10-24 18:09:10.809167','A',10,'Physical count adjustment','71','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (91,'2024-10-24 18:09:10.860340','A',10,'Physical count adjustment','72','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (92,'2024-10-24 18:09:10.908339','A',10,'Physical count adjustment','73','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (93,'2024-10-24 18:09:10.961679','A',10,'Physical count adjustment','74','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (94,'2024-10-24 18:09:11.009834','A',10,'Physical count adjustment','75','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (95,'2024-10-24 18:09:11.065477','A',10,'Physical count adjustment','76','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (96,'2024-10-24 18:18:49.420755','A',20,'Add to Inventory','77','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (104,'2024-10-24 18:46:34.799298','R',-1,'Remove','66','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (105,'2024-10-24 18:49:52.655330','R',-1,'Remove','66','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (106,'2024-10-24 19:08:25.285872','R',-2,'damaged broken','66','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (107,'2024-10-24 19:12:20.268129','R',-1,'Remove','66','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (108,'2024-10-24 19:15:47.334541','R',-2,'Remove','66','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (109,'2024-10-24 19:19:37.574635','R',-1,'Remove','66','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (110,'2024-10-24 19:21:17.226685','R',-1,'Remove','66','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (111,'2024-10-24 19:24:06.229863','R',-1,'Remove','66','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (112,'2024-10-24 19:26:45.086430','R',-1,'Remove','77','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (113,'2024-10-24 19:28:31.889822','R',-1,'Remove','77','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (114,'2024-10-24 19:33:01.491758','R',-1,'Remove','77','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (115,'2024-10-24 19:33:27.759373','R',-1,'broken item','77','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (116,'2024-10-24 19:34:35.355645','A',10,'Add to Inventory','78','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (117,'2024-10-24 19:34:52.074771','R',-10,'Remove','78','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (118,'2024-10-24 19:34:52.105403','R',-10,'Remove','77','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (119,'2024-10-24 19:38:26.392637','A',10,'Add to Inventory','79','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (120,'2024-10-24 19:38:48.442705','R',-10,'Remove','67','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (121,'2024-10-24 19:38:48.526700','R',-5,'Remove','79','3');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (122,'2024-11-06 11:46:05.309211','A',20,'Add to Inventory','80','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (123,'2024-11-06 11:46:32.956926','A',20,'Add to Inventory','81','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (124,'2024-11-06 11:47:01.209936','A',30,'Add to Inventory','82','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (125,'2024-11-06 11:47:23.053324','A',40,'Add to Inventory','83','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (126,'2024-11-06 11:47:50.739196','A',50,'Add to Inventory','84','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (127,'2024-11-06 11:48:25.251962','A',60,'Add to Inventory','85','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (128,'2024-11-06 11:49:54.876052','R',-2,'Remove','80','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (129,'2024-11-06 11:51:53.988771','D',1,'Broken eyepiece','82','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (130,'2024-11-06 11:56:37.065357','P',-1,'Physical count adjustment','82','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (131,'2024-11-06 11:56:37.167444','A',1,'Physical count adjustment','86','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (132,'2024-11-06 11:56:37.220635','P',-1,'Physical count adjustment','81','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (133,'2024-11-06 11:58:28.261148','A',1,'Physical count adjustment','87','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (134,'2024-11-06 12:06:53.156766','A',30,'Add to Inventory','88','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (135,'2024-11-06 12:07:19.260115','R',-10,'Remove from inventory','82','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (136,'2024-11-08 06:54:50.223390','A',2,'Add to Inventory','89','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (137,'2024-11-08 06:57:22.395136','R',-6,'Remove from inventory','77','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (138,'2024-11-08 06:59:55.819543','D',1,'broken','68','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (139,'2024-11-08 07:01:30.039741','A',1,'Physical count adjustment','90','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (140,'2024-11-08 16:56:49.831289','R',-5,'Remove from inventory','81','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (141,'2024-11-08 17:05:24.312089','P',-4,'Physical Count Adjustment','82','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (142,'2024-11-09 06:04:54.249349','A',10,'Add to Inventory','91','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (143,'2024-11-09 06:04:54.342351','A',10,'Add to Inventory','92','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (144,'2024-11-09 06:14:42.692624','A',10,'Add to Inventory','93','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (145,'2024-11-14 06:58:16.454455','A',30,'Add to Inventory','94','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (146,'2024-11-14 06:59:37.299089','R',-2,'Remove from inventory','94','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (147,'2024-11-14 07:01:55.637941','D',-1,'broken','94','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (148,'2024-11-14 07:07:04.191312','P',-7,'Physical Count Adjustment','94','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (149,'2024-11-14 11:39:05.473632','A',30,'Add to Inventory','102101202439690001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (150,'2024-11-14 11:41:47.544211','A',20,'Add to Inventory','102101202439690002','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (151,'2024-11-14 11:42:29.132324','A',40,'Add to Inventory','102101202400310001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (152,'2024-11-14 11:57:55.235141','A',10,'Add to Inventory','10220001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (153,'2024-11-14 13:46:10.630327','A',10,'Add to Inventory','10230001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (154,'2024-11-14 13:49:48.912915','A',10,'Add to Inventory','10250001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (155,'2024-11-14 14:25:58.253708','R',-5,'Remove from inventory','79','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (156,'2024-11-14 16:30:41.165686','A',20,'Add to Inventory','10250002','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (157,'2024-11-14 16:32:48.083887','R',5,'','68','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (158,'2024-11-14 16:33:37.348389','R',4,'Remove from inventory','68','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (159,'2024-11-14 16:33:37.373397','R',-1,'Remove from inventory','10250001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (160,'2024-11-14 16:33:50.762424','R',-3,'Remove from inventory','10250001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (161,'2024-11-14 16:44:16.730318','R',-2,'Remove from inventory','10250001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (162,'2024-11-14 16:52:19.903234','D',-4,'stolen all','10250001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (163,'2024-11-14 16:52:19.937254','D',-20,'stolen all','10250002','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (164,'2024-11-14 16:55:45.880784','A',20,'Add to Inventory','10230002','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (165,'2024-11-14 16:56:27.019673','D',-5,'lost','10230002','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (166,'2024-11-14 16:56:55.793304','D',-1,'spilled','10230001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (167,'2024-11-14 16:58:42.372417','R',-9,'Remove from inventory','10230001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (168,'2024-11-15 04:15:37.568584','A',20,'Add to Inventory','10260001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (169,'2024-11-15 07:33:32.825161','A',20,'Add to Inventory','10270001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (170,'2024-11-15 07:35:04.540583','R',-1,'Remove from inventory','70','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (171,'2024-11-15 07:37:36.401249','D',-2,'contaminated','10230002','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (172,'2024-11-15 08:12:37.450626','A',1,'Add to Inventory','102101202488850001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (173,'2024-11-15 08:15:22.876812','A',1,'Add to Inventory','102101202488850002','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (174,'2024-11-15 11:39:05.548018','R',-2,'Remove from inventory','91','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (175,'2024-11-15 16:32:34.170232','A',30,'Add to Inventory','10220002','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (176,'2024-11-16 07:22:14.236323','A',3,'Add to Inventory','10250003','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (177,'2024-11-16 07:25:46.342590','A',4,'Add to Inventory','10270002','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (178,'2024-11-16 07:26:17.691566','A',2,'Add to Inventory','10270003','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (179,'2024-11-16 12:17:28.706382','A',1,'Add to Inventory','102101202463160001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (180,'2024-11-16 12:18:00.368336','A',1,'Add to Inventory','102101202463160002','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (181,'2024-11-16 12:35:48.121782','R',-2,'Remove from inventory','91','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (182,'2024-11-16 12:36:21.687127','R',-1,'Remove from inventory','91','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (183,'2024-11-16 12:38:22.124808','R',-1,'Remove from inventory','102101202463160001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (184,'2024-11-17 06:29:35.485808','A',1,'Add to Inventory','102101202481630001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (185,'2024-11-17 07:43:24.936701','P',2,'Physical count adjustment','102101202410770001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (186,'2024-11-17 07:53:50.416845','P',1,'Physical count adjustment','94','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (187,'2024-11-17 07:54:31.880548','P',7,'Physical count adjustment','102101202410770002','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (188,'2024-11-17 08:04:03.002053','P',-1,'Physical Count Adjustment','90','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (189,'2024-11-17 08:04:03.004386','P',-2,'Physical Count Adjustment','102101202410770001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (190,'2024-11-17 08:04:17.524461','P',3,'Physical count adjustment','94','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (191,'2024-11-17 08:04:44.391048','P',2,'Physical count adjustment','91','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (192,'2024-11-17 08:04:53.368201','P',-1,'Physical count adjustment','92','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (193,'2024-11-17 10:50:35.983830','A',1,'Add to Inventory','102101202419390001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (194,'2024-11-17 10:55:28.945564','A',3,'Add to Inventory','102101202441690001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (195,'2024-11-17 10:58:28.298333','A',5,'Add to Inventory','102101202462390001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (196,'2024-11-17 11:01:01.016695','A',10,'Add to Inventory','102101202423770001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (197,'2024-11-17 11:01:55.967818','A',10,'Add to Inventory','102101202480370001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (198,'2024-11-17 11:04:48.513788','A',20,'Add to Inventory','102101202467110001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (199,'2024-11-17 11:08:20.643243','A',20,'Add to Inventory','102101202436070001','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (200,'2024-11-17 11:09:34.173232','A',1,'Add to Inventory','102101202436070002','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (201,'2024-11-17 11:10:09.218450','A',1,'Add to Inventory','102101202436070003','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (202,'2024-11-17 11:11:11.243025','A',1,'Add to Inventory','102101202436070004','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (203,'2024-11-18 10:18:21.318753','R',-1,'Remove from inventory','10250003','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (204,'2024-11-18 10:18:56.730099','R',-1,'Remove from inventory','10250003','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (205,'2024-11-18 10:28:14.581551','A',1,'Add to Inventory','10250004','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (206,'2024-11-18 10:31:44.654733','R',-1,'Remove from inventory','10250004','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (207,'2024-11-18 10:34:38.501468','A',1,'Add to Inventory','10250005','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (208,'2024-11-18 10:34:47.552950','R',-1,'Remove from inventory','10250005','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (209,'2024-11-18 10:35:07.243096','R',-1,'Remove from inventory','91','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (210,'2024-11-18 10:39:05.107431','R',-1,'Remove from inventory','91','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (211,'2024-11-18 10:40:02.138580','R',-1,'Remove from inventory','69','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (212,'2024-11-18 10:40:15.375278','A',3,'Add to Inventory','10230003','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (213,'2024-11-18 10:40:30.419405','A',1,'Add to Inventory','10250006','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (214,'2024-11-18 10:41:11.390146','D',-1,'contaminated','70','2');
INSERT INTO "core_item_handling" ("item_handling_id","timestamp","changes","qty","remarks","inventory_item_id","updated_by_id") VALUES (215,'2024-11-18 12:34:25.248138','R',-1,'Remove from inventory','10230002','2');
INSERT INTO "core_suppliers" ("suppliers_id","supplier_name","contact_person","contact_number","description","is_disabled","laboratory_id","email") VALUES ('1','ORS Lab',NULL,NULL,'sample desc',1,'1','orslab@gmail.com');
INSERT INTO "core_suppliers" ("suppliers_id","supplier_name","contact_person","contact_number","description","is_disabled","laboratory_id","email") VALUES ('2','Mercury Lab','Luis Ostia',NULL,'sample desc2',0,'1','mercury@gmail.com');
INSERT INTO "core_suppliers" ("suppliers_id","supplier_name","contact_person","contact_number","description","is_disabled","laboratory_id","email") VALUES ('3','Unilab',NULL,NULL,'san pedro',0,'1','unilab@gmail.com');
INSERT INTO "core_suppliers" ("suppliers_id","supplier_name","contact_person","contact_number","description","is_disabled","laboratory_id","email") VALUES ('4','generica',NULL,NULL,'las pinas',0,'1','generica@gmail.com');
INSERT INTO "core_suppliers" ("suppliers_id","supplier_name","contact_person","contact_number","description","is_disabled","laboratory_id","email") VALUES ('5','ABC Scientific Supplies','John Doe',2345678901,'Provides laboratory equipment and scientific instruments.',0,'2','abc@gmail.com');
INSERT INTO "core_suppliers" ("suppliers_id","supplier_name","contact_person","contact_number","description","is_disabled","laboratory_id","email") VALUES ('6','XYZ Lab Equipment','Jane Smith',9876543210,'Specializes in high-precision measurement tools and calibration services.',0,'2','xyz@gmail.com');
INSERT INTO "core_suppliers" ("suppliers_id","supplier_name","contact_person","contact_number","description","is_disabled","laboratory_id","email") VALUES ('7','TechLab Solutions','Michael Johnson',5551234567,'Offers a wide range of electronic testing devices and software solutions.',0,'2','techlab@gmail.com');
INSERT INTO "core_suppliers" ("suppliers_id","supplier_name","contact_person","contact_number","description","is_disabled","laboratory_id","email") VALUES ('10220246857','Meditech','',NULL,'meditech for medical materials',0,'1','meditech@gmail.com');
INSERT INTO "core_suppliers" ("suppliers_id","supplier_name","contact_person","contact_number","description","is_disabled","laboratory_id","email") VALUES ('10220245837','SciLab',NULL,922754732,'chemicals suppliers ',1,'1','scilab@gmail.com');
INSERT INTO "core_suppliers" ("suppliers_id","supplier_name","contact_person","contact_number","description","is_disabled","laboratory_id","email") VALUES ('10220247939','Precision Instruments Co.','John Doe',2345678901,'Supplier of high-precision measurement and testing instruments for various industries.',0,'90120243485','precision@instruments.com');
INSERT INTO "core_suppliers" ("suppliers_id","supplier_name","contact_person","contact_number","description","is_disabled","laboratory_id","email") VALUES ('10220246889','TestEquip Solutions','Jane Smith',3456789012,'Provider of a wide range of testing equipment and calibration services.
',0,'90120243485','info@testequip.com');
INSERT INTO "core_suppliers" ("suppliers_id","supplier_name","contact_person","contact_number","description","is_disabled","laboratory_id","email") VALUES ('10220245882','Accurate Testing Supplies','Michael Johnson',4567890123,'Distributor of reliable and accurate testing instruments for laboratories and industrial applications.',0,'90120243485','sales@accuratetesting.com');
INSERT INTO "core_suppliers" ("suppliers_id","supplier_name","contact_person","contact_number","description","is_disabled","laboratory_id","email") VALUES ('10220247836','GreenChem Solutions','Mr. John Doe',18005555678,'Eco-friendly cleaning agents

',0,'1','info@greenchem.com');
INSERT INTO "core_suppliers" ("suppliers_id","supplier_name","contact_person","contact_number","description","is_disabled","laboratory_id","email") VALUES ('10220242723','BioChem Labs','Ms. Emily Johnson',18005559876,'Laboratory-grade ethanol',0,'1','support@biochem.com');
INSERT INTO "core_user" ("password","last_login","user_id","firstname","lastname","email","is_deactivated","is_staff","is_superuser","date_joined","personal_id","username") VALUES ('pbkdf2_sha256$870000$CIsd1eN4rhiUOrAIoTbzhk$+dywwKDSbWGq7a/WEFQRXJ9+W46EFTfleRFHlyDd17I=','2024-11-18 08:27:53.747521','1','System','Admin','system.admin@dlsu.edu.ph',0,1,1,'2024-10-31 06:36:08.067298','1202','system.admin@dlsu.edu.ph');
INSERT INTO "core_user" ("password","last_login","user_id","firstname","lastname","email","is_deactivated","is_staff","is_superuser","date_joined","personal_id","username") VALUES ('','2024-11-18 21:14:44.831291','2','ken','uy','kenneth_uy@dlsu.edu.ph',0,0,0,'2024-10-28 09:45:35.136035','12027774','kenneth_uy');
INSERT INTO "core_user" ("password","last_login","user_id","firstname","lastname","email","is_deactivated","is_staff","is_superuser","date_joined","personal_id","username") VALUES ('','2024-11-17 11:59:45.436959','3','Luis','Ostia','luis_ostia@dlsu.edu.ph',0,0,0,'2024-10-28 09:45:35.136035',NULL,'luis_ostia@dlsu.edu.ph');
INSERT INTO "core_user" ("password","last_login","user_id","firstname","lastname","email","is_deactivated","is_staff","is_superuser","date_joined","personal_id","username") VALUES ('!ShikdXoIsvmXkJJSOYPRavdzIcySnka53r3jfAys','2024-11-12 11:46:45.902973','4','','','tacticalforce58@dlsu.edu.ph',0,0,0,'2024-11-05 17:14:35.671690',NULL,'tf58');
INSERT INTO "core_user" ("password","last_login","user_id","firstname","lastname","email","is_deactivated","is_staff","is_superuser","date_joined","personal_id","username") VALUES ('pbkdf2_sha256$870000$kfhVELcGmXq1u0ECHBcWAQ$GFADbAYlzQdNoxPiFEZtFKbcUGKyHkZCO2AcetPnnEs=',NULL,'5','Merylle','Salvador','merylle_salvador@dlsu.edu.ph',0,0,0,'2024-10-28 09:57:15.001251',NULL,'merylle_salvador');
INSERT INTO "core_user" ("password","last_login","user_id","firstname","lastname","email","is_deactivated","is_staff","is_superuser","date_joined","personal_id","username") VALUES ('pbkdf2_sha256$870000$mijkSsG028vqHya764IS0U$i3BuhalQ4tzReWtSd1m8aSMYCsXsee9uj84bnuzuV6o=',NULL,'9','Dominique','Conde','dominique_conde@dlsu.edu.ph',0,0,0,'2024-10-28 10:40:28.846284','12028458','dom_conde');
INSERT INTO "core_user" ("password","last_login","user_id","firstname","lastname","email","is_deactivated","is_staff","is_superuser","date_joined","personal_id","username") VALUES ('pbkdf2_sha256$870000$Mbz7qJhLtF7P6OM7s27xjI$03Ki/O3jwVri9lMNJjYCR8iShM0LCm3bSlHqGIFsmwE=','2024-11-18 21:25:27.068403','11','chem','labcoord','chem_labcoord@gmail.com',0,0,0,'2024-10-29 16:06:45.001248','','chem_labcoord@gmail.com');
INSERT INTO "core_user" ("password","last_login","user_id","firstname","lastname","email","is_deactivated","is_staff","is_superuser","date_joined","personal_id","username") VALUES ('pbkdf2_sha256$870000$o2ygBuGHGmiMu3gZvdZLj9$kXnyPxGpKsguK/7RxvzP4EMHzY8h+RtpDORQZrR1RtU=','2024-11-18 07:39:39.234819','13','chem','labtech','chem_labtech@gmail.com',0,0,0,'2024-10-29 15:27:51.246683','','chem_labtech@gmail.com');
INSERT INTO "core_user" ("password","last_login","user_id","firstname","lastname","email","is_deactivated","is_staff","is_superuser","date_joined","personal_id","username") VALUES ('pbkdf2_sha256$870000$Qp84ctuIPoB4HZ0RhPWmcx$tNvjtbNp2PmOBUCAs7gF4K9+3poproPs+FBd9BPTJ3Y=','2024-11-01 06:30:38.955547','16','System2','Admin2','system.admin2@dlsu.edu.ph',0,0,1,'2024-11-01 06:30:28.428054','','system.admin2@dlsu.edu.ph');
INSERT INTO "core_user" ("password","last_login","user_id","firstname","lastname","email","is_deactivated","is_staff","is_superuser","date_joined","personal_id","username") VALUES ('','2024-11-12 11:06:40.982240','18','ken2','uy2','kennethmyronduy@dlsu.edu.ph',0,0,0,'2024-10-28 09:45:35.136035','12027774','kennethmyronduy@gmail.com');
INSERT INTO "core_user" ("password","last_login","user_id","firstname","lastname","email","is_deactivated","is_staff","is_superuser","date_joined","personal_id","username") VALUES ('pbkdf2_sha256$870000$nfRivelBISrXcpeHaomIbM$NkSWVj/EbRbR/UcpBoYx8UtzWXPiXKnY7wmGQrUzt7U=',NULL,'19','chem','depthead','chem_depthead@gmail.com',0,0,0,'2024-11-04 11:51:19.185730','','chem_depthead@gmail.com');
INSERT INTO "core_user" ("password","last_login","user_id","firstname","lastname","email","is_deactivated","is_staff","is_superuser","date_joined","personal_id","username") VALUES ('pbkdf2_sha256$870000$h0xx3UI5Qm2VWLkYoWefIx$JPCz7z/Znf2VCDpDTW18s/BSoPTbfcfXLC3si71Qp6g=',NULL,'20','intru','labcoord','instru_labcoord@dlsu.edu.ph',0,0,0,'2024-11-04 12:09:06.947961','12028458','instru_labcoord@dlsu.edu.ph');
INSERT INTO "core_user" ("password","last_login","user_id","firstname","lastname","email","is_deactivated","is_staff","is_superuser","date_joined","personal_id","username") VALUES ('pbkdf2_sha256$870000$Ms9hSXdgU77YMK61G3geml$eXC6pASdWo1xIEavIW3kcUmSwiWBDaDqQxtqLU8WXQo=',NULL,'20242583','phys','labcoord','phys_labcoord@dlsu.edu.ph',0,0,0,'2024-11-06 11:12:07.893078','12028458','phys_labcoord@dlsu.edu.ph');
INSERT INTO "core_user" ("password","last_login","user_id","firstname","lastname","email","is_deactivated","is_staff","is_superuser","date_joined","personal_id","username") VALUES ('pbkdf2_sha256$870000$N73NI20gq2CEpZbjxu2DNR$ug5FrJb3N2ha9Hf8M3q1IQ7g0mSNLt0rWlJzOTu1v+I=',NULL,'20245407','phys','labtech','phys_labtech@dlsu.edu.ph',0,0,0,'2024-11-06 11:16:25.975876','12028458','phys_labtech@dlsu.edu.ph');
INSERT INTO "core_user" ("password","last_login","user_id","firstname","lastname","email","is_deactivated","is_staff","is_superuser","date_joined","personal_id","username") VALUES ('pbkdf2_sha256$870000$cZiH0zdDU4fIddRZpPgnST$lpAV/HNcO+6L+kFnLLwy/Z6mgxzXM7PqFJNY4dkKDQo=','2024-11-10 18:49:37.071438','20248922','Chachi','Ostia','chachi_ostia@gmail.com',0,0,0,'2024-11-10 18:49:20.421065','120143143','chachi_ostia@gmail.com');
INSERT INTO "core_user" ("password","last_login","user_id","firstname","lastname","email","is_deactivated","is_staff","is_superuser","date_joined","personal_id","username") VALUES ('pbkdf2_sha256$870000$BMbSMJZRESo4SmaBAwoLlL$uXWdx46DmZC1pDBThofUHjm7r8MJZNsY4hViocU57m4=','2024-11-12 12:26:37.431365','20245133','ken','uy','tacticalforce58@gmail.com',0,0,0,'2024-11-12 12:24:06.939224',NULL,'');
INSERT INTO "core_user" ("password","last_login","user_id","firstname","lastname","email","is_deactivated","is_staff","is_superuser","date_joined","personal_id","username") VALUES ('pbkdf2_sha256$870000$4ZmTmBQ2RvJ9uETTirNcds$vSh5Hon/YntqF0C/gW6mCrpMkeftCJzFu2LTTuIimXs=',NULL,'20245694','phys','student','phys_student@dlsu.edu.ph',0,0,0,'2024-11-13 12:47:53.923161','120304','phys_student@dlsu.edu.ph');
INSERT INTO "core_user" ("password","last_login","user_id","firstname","lastname","email","is_deactivated","is_staff","is_superuser","date_joined","personal_id","username") VALUES ('pbkdf2_sha256$870000$LKh88AmVodaSrpxYi5olWu$y7lEZoz6i4zcObc1RlwsCJaQPgYptEH2Dv0jRQ0MG/E=','2024-11-17 16:34:40.695199','20241125','Biology','LabCoor','biologylabcoor@dlsu.edu.ph',0,0,0,'2024-11-17 14:44:54.717767','11507889','biologylabcoor@dlsu.edu.ph');
INSERT INTO "core_user" ("password","last_login","user_id","firstname","lastname","email","is_deactivated","is_staff","is_superuser","date_joined","personal_id","username") VALUES ('pbkdf2_sha256$870000$3wlMeQ3e3Ja0ng4PVsZwPl$dHfbm+rnthiPfhbqyG0akO5GHiwHm6ku1UmmbvkPk+I=',NULL,'20248874','Biology','LabTech','biologylabtech@dlsu.edu.ph',0,0,0,'2024-11-17 14:45:08.693624','11569887','biologylabtech@dlsu.edu.ph');
INSERT INTO "core_user" ("password","last_login","user_id","firstname","lastname","email","is_deactivated","is_staff","is_superuser","date_joined","personal_id","username") VALUES ('pbkdf2_sha256$870000$syOTH9fJIfJWz7P57vN96V$3a1y6+uGj0TMuZpQ3HwgQJ3AQLshxEGh5zsxLdSbArU=','2024-11-17 14:46:06.293498','20246982','Biology','Student','biologystudent@dlsu.edu.ph',0,0,0,'2024-11-17 14:45:38.546606',NULL,NULL);
INSERT INTO "core_user" ("password","last_login","user_id","firstname","lastname","email","is_deactivated","is_staff","is_superuser","date_joined","personal_id","username") VALUES ('pbkdf2_sha256$870000$WCRrEvCcW072Bp1Lxrf98r$QbRKStc/pj+qGGl4vAb6vuJZImEzLaEHsRy/Ec0sdSg=','2024-11-18 21:25:45.905810','20244396','Chem','Student','chem_student@dlsu.edu.ph',0,0,0,'2024-11-18 07:22:49.415580','None','ChemStudent');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('1','Beaker',0,0,1,1,1,'1',2,NULL,0,'{"Nature": "Non-Organic", "Grade": "A+", "Location": "GK305", "Kind": "Solid"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('2','Ethanol',30,1,0,1,1,'1',1,4,0,'{"Nature": "solid", "Grade": "good", "chemical formula": "C\u2082H\u2086O", "synonyms": "Alcohol"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('3','Sodium Chloride',10,1,0,1,1,'1',1,2,0,'{"Nature": "organic", "Grade": "normal", "Location": "gk204", "Kind": "solid"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('4','Beaker',0,0,1,1,1,'1',2,NULL,0,'{"Nature": "organic", "Brand": "pyrex", "Location": "gk204", "Status": "good", "L or S": "L"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('5','Pitot Tube',10,0,0,1,0,'1',2,NULL,0,'{"Nature": "ffg", "Brand": "pyrex", "Location": "gk204", "Status": "good", "L or S": "L"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('6','Hydrogen',0,0,0,1,1,'1',1,NULL,0,'{"Nature": "organic", "Grade": "normal", "Location": "gk204", "Kind": "solid"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('7','Iodine',0,0,0,1,1,'1',1,NULL,0,'{"Nature": "organic", "Grade": "normal", "Location": "gk204", "Kind": "liquid"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('8','Iodine',0,0,1,1,1,'1',1,NULL,0,'{"Nature": "organic", "Grade": "normal", "Location": "gk204", "Kind": "liquid"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('9','Iodine',0,0,1,1,1,'1',1,NULL,0,'{"Nature": "organic", "Grade": "normal", "Location": "gk204", "Kind": "liquid"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10','Iodine2',0,0,1,1,1,'1',1,NULL,0,'{"Nature": "organic", "Grade": "normal", "Location": "gk204", "Kind": "liquid"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('11','Hydrogen Peroxide',0,0,0,1,1,'1',1,NULL,0,'{"Nature": "Solid", "Grade": "N", "chemical formula": "h2o2", "synonyms": "agua oxinada, something"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('12','Sulphuric Acid ',10,1,1,1,1,'1',1,NULL,0,'{"Nature": "acid", "Grade": "normal", "Location": "gk204", "Kind": "liquid"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('13','Sulphuric Acid ',10,1,1,1,1,'1',1,NULL,0,'{"Nature": "acid", "Grade": "normal", "Location": "gk204", "Kind": "liquid"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('14','Sulphuric Acid ',10,1,0,1,1,'1',1,3,0,'{"Nature": "acid", "Grade": "normal", "Location": "gk204", "Kind": "liquid"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('15','Laptop',0,0,1,0,0,'1',3,NULL,0,'{"Brand (Apple, Windows)": null, "Grade (A, B, C)": null}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('16','Beaker',0,0,0,1,0,'1',2,NULL,1,'{"Nature": "organic", "Brand": null, "Location": "gk204", "Status": null, "L or S": null, "Capacity": 200, "Dimension": "mL"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('17','Cobalt CHloride',0,0,1,1,1,'1',1,NULL,0,'{"Nature": "", "Grade": "", "Location": "", "Kind": "", "chemical formula": "", "synonyms": ""}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('18','pH meters',10,0,1,0,0,'1',NULL,NULL,0,'{"Capacity (1L, 2L, 3L)": "None", "Brand": "pyrex"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('19','Ethanol',0,0,1,1,1,'1',1,NULL,0,'{"Nature": "organic", "Grade": "normal", "Location": "gk204", "Kind": "solid", "Amount": "5", "Dimension": "L"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120243849','Ammeter',0,0,0,0,0,'2',4,NULL,0,'{"Brand": "Murata"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120243969','Galvanometer',3,0,0,0,0,'2',4,NULL,0,'{"Brand": "ScannerMAX"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120240031','Microscope',0,0,0,0,0,'2',4,NULL,0,'{"Brand": "Olympus BX53"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120241950','Voltmeter',0,0,0,0,0,'2',4,NULL,0,'{"Brand": "Fluke 87V"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120247977','Oscilloscope',0,0,0,0,0,'2',4,NULL,0,'{"Brand": "Tektronix TBS1052B"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120243666','Spectrometer',0,0,0,0,0,'2',4,NULL,0,'{"Brand": "Ocean Optics"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120245963','Beakers',0,0,0,0,0,'2',8,NULL,0,'{}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120246341','Flasks',0,0,0,0,0,'2',8,NULL,0,'{}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120241077','Acetylene',0,0,0,1,1,'1',1,NULL,0,'{"Nature": "solid", "Grade": "good", "chemical formula": "ace", "synonyms": "acetyl"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120242485','Acetylene',0,0,1,0,0,'1',NULL,NULL,0,'{"Brand": "Linde", "Cylinder (5 L, 10 L)": null}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120246258','Acetylene',0,0,1,0,0,'1',NULL,NULL,0,'{"Brand": "Linde", "Cylinder (5 L, 10 L)": null}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120247714','pH Meter',5,1,0,0,0,'1',3,NULL,0,'{"Grade (A, B, C)": "B"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120248885','Multimeter',0,0,0,0,0,'1',3,NULL,1,'{"Grade (A, B, C)": "A"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120247432','Multimeter',0,0,1,0,0,'90120243485',12,NULL,1,'{"Brand": "Bosch"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120246316','Multimeter',0,0,0,0,0,'90120243485',12,NULL,1,'{"Brand": "Bosch"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120241939','Bunsen Burner',0,0,0,0,0,'1',3,NULL,1,'{"Grade (A, B, C)": "A"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120248163','Centrifuge',0,0,0,0,0,'1',3,NULL,1,'{"Grade (A, B, C)": "A"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120240186','Potassium Nitrate',5,1,0,0,0,'1',1,NULL,0,'{"Nature": "Solid", "Grade": "Reagent", "chemical formula": null, "synonyms": "Saltpeter"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120242377','Calcium Carbonate',10,0,0,0,0,'1',1,NULL,0,'{"Nature": "Solid", "Grade": "Analytical", "chemical formula": null, "synonyms": "Limestone"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120246239','Ammonium Sulfate',8,1,0,0,0,'1',1,NULL,0,'{"Nature": "Solid", "Grade": "Laboratory", "chemical formula": null, "synonyms": "Diammonium sulfate"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120243607','Magnesium Sulfate',7,0,0,0,0,'1',1,NULL,1,'{"Nature": "Solid", "Grade": "Reagent", "chemical formula": null, "synonyms": "Epsom salt"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120249488','Acetic Acid',0,1,1,1,1,'1',1,NULL,0,'{"Nature": "Liquid", "Grade": "Glacial", "chemical formula": null, "synonyms": "Ethanoic acid"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120244169','Acetic Acid',0,0,0,0,0,'1',1,NULL,0,'{"Nature": "Non-Organic", "Grade": "A+ss", "chemical formula": "AcA", "synonyms": "HAHA"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120248037','Erlenmeyer Flask',15,0,0,0,0,'1',2,NULL,0,'{"Nature": "Glass", "Brand": "Kimble", "Location": "Shelf B", "Status": "Used", "L or S": null, "Capacity": "250 mL", "Dimension": "8 cm x 14 cm"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120249352','Graduated Cylinder',0,0,0,0,0,'1',2,NULL,0,'{"Nature": "Glass", "Brand": "Corning", "Location": "Shelf C", "Status": "New", "L or S": null, "Capacity": "100 mL", "Dimension": "3 cm x 30 cm"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120246711','Test Tube',0,0,0,0,0,'1',2,NULL,0,'{"Nature": "Glass", "Brand": "VWR", "Location": "Shelf D", "Status": "Used", "L or S": null, "Capacity": "10 mL", "Dimension": "1.5 cm x 10 cm"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120247205','Volumetric Flask',0,0,0,0,0,'1',2,NULL,0,'{"Nature": "Glass", "Brand": "Fisher", "Location": "Shelf E", "Status": "New", "L or S": null, "Capacity": "1000 mL", "Dimension": "12 cm x 25 cm"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120247264','Hot Plate',0,0,0,0,0,'1',3,NULL,1,'{"Grade (A, B, C)": "B"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120242830','Microscope',0,0,0,0,0,'1',3,NULL,1,'{"Grade (A, B, C)": "B"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120247791','Bunsen Burner',0,0,1,0,0,'1',3,NULL,1,'{"Grade (A, B, C)": "C"}');
INSERT INTO "core_item_description" ("item_id","item_name","alert_qty","rec_expiration","is_disabled","allow_borrow","is_consumable","laboratory_id","itemType_id","qty_limit","rec_per_inv","add_cols") VALUES ('10120246430','pH Meter',0,0,0,0,0,'1',3,NULL,1,'{"Grade (A, B, C)": "C"}');
INSERT INTO "core_rooms" ("room_id","name","capacity","description","is_disabled","is_reservable","laboratory_id","blocked_time") VALUES ('1','SJ401',45,'Chem lab',1,0,'1','{}');
INSERT INTO "core_rooms" ("room_id","name","capacity","description","is_disabled","is_reservable","laboratory_id","blocked_time") VALUES ('2','SJ402',45,'chem lab 2',1,0,'1','{}');
INSERT INTO "core_rooms" ("room_id","name","capacity","description","is_disabled","is_reservable","laboratory_id","blocked_time") VALUES ('3','SJ403',45,'chem lab 3',1,0,'1','{}');
INSERT INTO "core_rooms" ("room_id","name","capacity","description","is_disabled","is_reservable","laboratory_id","blocked_time") VALUES ('5','SJ404',45,'chem lab 4',1,0,'1','{}');
INSERT INTO "core_rooms" ("room_id","name","capacity","description","is_disabled","is_reservable","laboratory_id","blocked_time") VALUES ('6','SJ405',45,'chem lab 5',1,0,'1','{}');
INSERT INTO "core_rooms" ("room_id","name","capacity","description","is_disabled","is_reservable","laboratory_id","blocked_time") VALUES ('9','SJ407',45,'chem lab 6',1,0,'1','{}');
INSERT INTO "core_rooms" ("room_id","name","capacity","description","is_disabled","is_reservable","laboratory_id","blocked_time") VALUES ('10','SJ408',45,'chem lab test add',1,0,'1','{}');
INSERT INTO "core_rooms" ("room_id","name","capacity","description","is_disabled","is_reservable","laboratory_id","blocked_time") VALUES ('11','SJ404',45,'chem lab test edit',1,0,'1','{}');
INSERT INTO "core_rooms" ("room_id","name","capacity","description","is_disabled","is_reservable","laboratory_id","blocked_time") VALUES ('12','UV vis',23,'',1,1,'1','{}');
INSERT INTO "core_rooms" ("room_id","name","capacity","description","is_disabled","is_reservable","laboratory_id","blocked_time") VALUES ('00220248258','SJ404',45,'chem lab 4',1,1,'1','{}');
INSERT INTO "core_rooms" ("room_id","name","capacity","description","is_disabled","is_reservable","laboratory_id","blocked_time") VALUES ('00220247872','SJ407',45,'chem lab 4',1,1,'1','{}');
INSERT INTO "core_rooms" ("room_id","name","capacity","description","is_disabled","is_reservable","laboratory_id","blocked_time") VALUES ('00220246361','SJ503',45,'lecture room',1,1,'1','{}');
INSERT INTO "core_rooms" ("room_id","name","capacity","description","is_disabled","is_reservable","laboratory_id","blocked_time") VALUES ('90220247773','SJ402',56,'chem room lecture lab',0,1,'1','{"Monday": ["7:30-9:00", "9:15-10:45", "11:00-12:30"], "Tuesday": ["7:30-9:00"], "Wednesday": ["7:30-9:00"], "Thursday": ["7:30-9:00"], "Friday": ["7:30-9:00"], "Saturday": ["7:30-9:00"], "Sunday": ["7:30-9:00"]}');
INSERT INTO "core_rooms" ("room_id","name","capacity","description","is_disabled","is_reservable","laboratory_id","blocked_time") VALUES ('90220246403','SJ403',45,'lecture lab 2',0,1,'1','{}');
INSERT INTO "core_rooms" ("room_id","name","capacity","description","is_disabled","is_reservable","laboratory_id","blocked_time") VALUES ('90220243443','SJ404',45,'lecture lab 3',0,1,'1','{}');
INSERT INTO "core_rooms" ("room_id","name","capacity","description","is_disabled","is_reservable","laboratory_id","blocked_time") VALUES ('90220243550','V103',23,'Machine Room',0,1,'90120243485','{}');
INSERT INTO "core_rooms" ("room_id","name","capacity","description","is_disabled","is_reservable","laboratory_id","blocked_time") VALUES ('90220240420','V102',23,'Thermo Room',0,1,'90120243485','{}');
CREATE UNIQUE INDEX IF NOT EXISTS "auth_group_permissions_group_id_permission_id_0cd325b0_uniq" ON "auth_group_permissions" (
	"group_id",
	"permission_id"
);
CREATE INDEX IF NOT EXISTS "auth_group_permissions_group_id_b120cbf9" ON "auth_group_permissions" (
	"group_id"
);
CREATE INDEX IF NOT EXISTS "auth_group_permissions_permission_id_84c5c92e" ON "auth_group_permissions" (
	"permission_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "auth_user_groups_user_id_group_id_94350c0c_uniq" ON "auth_user_groups" (
	"user_id",
	"group_id"
);
CREATE INDEX IF NOT EXISTS "auth_user_groups_user_id_6a12ed8b" ON "auth_user_groups" (
	"user_id"
);
CREATE INDEX IF NOT EXISTS "auth_user_groups_group_id_97559544" ON "auth_user_groups" (
	"group_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "auth_user_user_permissions_user_id_permission_id_14a6b632_uniq" ON "auth_user_user_permissions" (
	"user_id",
	"permission_id"
);
CREATE INDEX IF NOT EXISTS "auth_user_user_permissions_user_id_a95ead1b" ON "auth_user_user_permissions" (
	"user_id"
);
CREATE INDEX IF NOT EXISTS "auth_user_user_permissions_permission_id_1fbb5f2c" ON "auth_user_user_permissions" (
	"permission_id"
);
CREATE INDEX IF NOT EXISTS "account_emailconfirmation_email_address_id_5b7f8c58" ON "account_emailconfirmation" (
	"email_address_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "django_content_type_app_label_model_76bd3d3b_uniq" ON "django_content_type" (
	"app_label",
	"model"
);
CREATE UNIQUE INDEX IF NOT EXISTS "auth_permission_content_type_id_codename_01ab375a_uniq" ON "auth_permission" (
	"content_type_id",
	"codename"
);
CREATE INDEX IF NOT EXISTS "auth_permission_content_type_id_2f476e4b" ON "auth_permission" (
	"content_type_id"
);
CREATE INDEX IF NOT EXISTS "django_session_expire_date_a5c62663" ON "django_session" (
	"expire_date"
);
CREATE UNIQUE INDEX IF NOT EXISTS "socialaccount_socialapp_sites_socialapp_id_site_id_71a9a768_uniq" ON "socialaccount_socialapp_sites" (
	"socialapp_id",
	"site_id"
);
CREATE INDEX IF NOT EXISTS "socialaccount_socialapp_sites_socialapp_id_97fb6e7d" ON "socialaccount_socialapp_sites" (
	"socialapp_id"
);
CREATE INDEX IF NOT EXISTS "socialaccount_socialapp_sites_site_id_2579dee5" ON "socialaccount_socialapp_sites" (
	"site_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "socialaccount_socialtoken_app_id_account_id_fca4e0ac_uniq" ON "socialaccount_socialtoken" (
	"app_id",
	"account_id"
);
CREATE INDEX IF NOT EXISTS "socialaccount_socialtoken_account_id_951f210e" ON "socialaccount_socialtoken" (
	"account_id"
);
CREATE INDEX IF NOT EXISTS "socialaccount_socialtoken_app_id_636a42d7" ON "socialaccount_socialtoken" (
	"app_id"
);
CREATE INDEX IF NOT EXISTS "core_permissions_module_id_f3a7c6ca" ON "core_permissions" (
	"module_id"
);
CREATE INDEX IF NOT EXISTS "django_admin_log_content_type_id_c4bce8eb" ON "django_admin_log" (
	"content_type_id"
);
CREATE INDEX IF NOT EXISTS "django_admin_log_user_id_c564eba6" ON "django_admin_log" (
	"user_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "account_emailaddress_user_id_email_987c8728_uniq" ON "account_emailaddress" (
	"user_id",
	"email"
);
CREATE UNIQUE INDEX IF NOT EXISTS "unique_verified_email" ON "account_emailaddress" (
	"email"
) WHERE "verified";
CREATE UNIQUE INDEX IF NOT EXISTS "unique_primary_email" ON "account_emailaddress" (
	"user_id",
	"primary"
) WHERE "primary";
CREATE INDEX IF NOT EXISTS "account_emailaddress_email_03be32b2" ON "account_emailaddress" (
	"email"
);
CREATE INDEX IF NOT EXISTS "account_emailaddress_user_id_2c513194" ON "account_emailaddress" (
	"user_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "socialaccount_socialaccount_provider_uid_fc810c6e_uniq" ON "socialaccount_socialaccount" (
	"provider",
	"uid"
);
CREATE INDEX IF NOT EXISTS "socialaccount_socialaccount_user_id_8146e70c" ON "socialaccount_socialaccount" (
	"user_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "core_borrowed_items_borrow_id_item_id_a957da68_uniq" ON "core_borrowed_items" (
	"borrow_id",
	"item_id"
);
CREATE INDEX IF NOT EXISTS "core_borrowed_items_borrow_id_9019ab22" ON "core_borrowed_items" (
	"borrow_id"
);
CREATE INDEX IF NOT EXISTS "core_borrowed_items_item_id_57af546b" ON "core_borrowed_items" (
	"item_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "core_laboratory_permissions_role_id_laboratory_id_permissions_id_24944900_uniq" ON "core_laboratory_permissions" (
	"role_id",
	"laboratory_id",
	"permissions_id"
);
CREATE INDEX IF NOT EXISTS "core_laboratory_permissions_permissions_id_41789e3d" ON "core_laboratory_permissions" (
	"permissions_id"
);
CREATE INDEX IF NOT EXISTS "core_laboratory_permissions_laboratory_id_e02dcadd" ON "core_laboratory_permissions" (
	"laboratory_id"
);
CREATE INDEX IF NOT EXISTS "core_laboratory_permissions_role_id_fda8b80e" ON "core_laboratory_permissions" (
	"role_id"
);
CREATE INDEX IF NOT EXISTS "core_item_types_laboratory_id_6bdc239f" ON "core_item_types" (
	"laboratory_id"
);
CREATE INDEX IF NOT EXISTS "core_borrow_info_approved_by_id_660d5ff4" ON "core_borrow_info" (
	"approved_by_id"
);
CREATE INDEX IF NOT EXISTS "core_borrow_info_laboratory_id_f00ec501" ON "core_borrow_info" (
	"laboratory_id"
);
CREATE INDEX IF NOT EXISTS "core_borrow_info_user_id_666f1b4a" ON "core_borrow_info" (
	"user_id"
);
CREATE INDEX IF NOT EXISTS "core_laboratory_roles_laboratory_id_fa98590f" ON "core_laboratory_roles" (
	"laboratory_id"
);
CREATE INDEX IF NOT EXISTS "core_reported_items_borrow_id_2c91bcb3" ON "core_reported_items" (
	"borrow_id"
);
CREATE INDEX IF NOT EXISTS "core_reported_items_item_id_1c1a1b8d" ON "core_reported_items" (
	"item_id"
);
CREATE INDEX IF NOT EXISTS "core_reported_items_laboratory_id_d3fb1b2a" ON "core_reported_items" (
	"laboratory_id"
);
CREATE INDEX IF NOT EXISTS "core_reported_items_user_id_e176eec4" ON "core_reported_items" (
	"user_id"
);
CREATE INDEX IF NOT EXISTS "core_laboratory_users_laboratory_id_0f3a812c" ON "core_laboratory_users" (
	"laboratory_id"
);
CREATE INDEX IF NOT EXISTS "core_laboratory_users_role_id_fa817d1a" ON "core_laboratory_users" (
	"role_id"
);
CREATE INDEX IF NOT EXISTS "core_laboratory_users_user_id_35bb59b1" ON "core_laboratory_users" (
	"user_id"
);
CREATE INDEX IF NOT EXISTS "core_reservation_config_laboratory_id_4f833299" ON "core_reservation_config" (
	"laboratory_id"
);
CREATE INDEX IF NOT EXISTS "core_laboratory_reservations_room_id_b9d5ad8a" ON "core_laboratory_reservations" (
	"room_id"
);
CREATE INDEX IF NOT EXISTS "core_laboratory_reservations_user_id_07753dec" ON "core_laboratory_reservations" (
	"user_id"
);
CREATE INDEX IF NOT EXISTS "core_laboratory_reservations_laboratory_id_9145227f" ON "core_laboratory_reservations" (
	"laboratory_id"
);
CREATE INDEX IF NOT EXISTS "core_item_inventory_item_id_08cd8b93" ON "core_item_inventory" (
	"item_id"
);
CREATE INDEX IF NOT EXISTS "core_item_inventory_supplier_id_6be69ccf" ON "core_item_inventory" (
	"supplier_id"
);
CREATE INDEX IF NOT EXISTS "core_item_handling_inventory_item_id_0453f3f1" ON "core_item_handling" (
	"inventory_item_id"
);
CREATE INDEX IF NOT EXISTS "core_item_handling_updated_by_id_69dbe00f" ON "core_item_handling" (
	"updated_by_id"
);
CREATE INDEX IF NOT EXISTS "core_suppliers_laboratory_id_1ca623d7" ON "core_suppliers" (
	"laboratory_id"
);
CREATE INDEX IF NOT EXISTS "core_item_description_laboratory_id_544e816d" ON "core_item_description" (
	"laboratory_id"
);
CREATE INDEX IF NOT EXISTS "core_item_description_itemType_id_175cb0c4" ON "core_item_description" (
	"itemType_id"
);
CREATE INDEX IF NOT EXISTS "core_rooms_laboratory_id_4036fb4d" ON "core_rooms" (
	"laboratory_id"
);
COMMIT;
