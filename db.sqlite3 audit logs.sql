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
	FOREIGN KEY("permission_id") REFERENCES "auth_permission"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("group_id") REFERENCES "auth_group"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "auth_user_groups" (
	"id"	integer NOT NULL,
	"user_id"	integer NOT NULL,
	"group_id"	integer NOT NULL,
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("group_id") REFERENCES "auth_group"("id") DEFERRABLE INITIALLY DEFERRED,
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
	FOREIGN KEY("user_id") REFERENCES "core_user"("user_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("content_type_id") REFERENCES "django_content_type"("id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "account_emailaddress" (
	"id"	integer NOT NULL,
	"email"	varchar(254) NOT NULL,
	"verified"	bool NOT NULL,
	"primary"	bool NOT NULL,
	"user_id"	varchar(20) NOT NULL,
	FOREIGN KEY("user_id") REFERENCES "core_user"("user_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "socialaccount_socialaccount" (
	"id"	integer NOT NULL,
	"provider"	varchar(200) NOT NULL,
	"uid"	varchar(191) NOT NULL,
	"last_login"	datetime NOT NULL,
	"date_joined"	datetime NOT NULL,
	"extra_data"	text NOT NULL CHECK((JSON_VALID("extra_data") OR "extra_data" IS NULL)),
	"user_id"	varchar(20) NOT NULL,
	FOREIGN KEY("user_id") REFERENCES "core_user"("user_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "core_borrowed_items" (
	"id"	integer NOT NULL,
	"qty"	integer,
	"returned_qty"	integer NOT NULL,
	"remarks"	varchar(1),
	"borrow_id"	varchar(20) NOT NULL,
	"item_id"	varchar(20) NOT NULL,
	"unit"	varchar(10),
	"inventory_item"	varchar(255),
	FOREIGN KEY("borrow_id") REFERENCES "core_borrow_info"("borrow_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("item_id") REFERENCES "core_item_description"("item_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
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
	FOREIGN KEY("laboratory_id") REFERENCES "core_laboratory"("laboratory_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("role_id") REFERENCES "core_laboratory_roles"("roles_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("permissions_id") REFERENCES "core_permissions"("permission_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "core_item_types" (
	"itemType_id"	integer NOT NULL,
	"itemType_name"	varchar(45),
	"add_cols"	text NOT NULL,
	"is_consumable"	bool NOT NULL,
	"laboratory_id"	varchar(20) NOT NULL,
	FOREIGN KEY("laboratory_id") REFERENCES "core_laboratory"("laboratory_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("itemType_id" AUTOINCREMENT)
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
	FOREIGN KEY("user_id") REFERENCES "core_user"("user_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("item_id") REFERENCES "core_item_description"("item_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("borrow_id") REFERENCES "core_borrow_info"("borrow_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("laboratory_id") REFERENCES "core_laboratory"("laboratory_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("report_id")
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
CREATE TABLE IF NOT EXISTS "core_notification" (
	"id"	integer NOT NULL,
	"message"	varchar(255) NOT NULL,
	"is_read"	bool NOT NULL,
	"created_at"	datetime NOT NULL,
	"user_id"	varchar(20) NOT NULL,
	FOREIGN KEY("user_id") REFERENCES "core_user"("user_id") DEFERRABLE INITIALLY DEFERRED,
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
	"filled_approval_form"	varchar(100),
	"laboratory_id"	varchar(20) NOT NULL,
	"user_id"	varchar(20),
	"room_id"	varchar(20),
	"table_id"	integer,
	FOREIGN KEY("table_id") REFERENCES "core_roomtable"("table_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("user_id") REFERENCES "core_user"("user_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("room_id") REFERENCES "core_rooms"("room_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("laboratory_id") REFERENCES "core_laboratory"("laboratory_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("reservation_id")
);
CREATE TABLE IF NOT EXISTS "core_roomtable" (
	"table_id"	integer NOT NULL,
	"table_name"	varchar(45),
	"capacity"	integer NOT NULL,
	"room_id"	varchar(20) NOT NULL,
	"blocked_time"	text NOT NULL CHECK((JSON_VALID("blocked_time") OR "blocked_time" IS NULL)),
	FOREIGN KEY("room_id") REFERENCES "core_rooms"("room_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("table_id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "core_item_expirations" (
	"expired_date"	date,
	"next_maintenance_date"	date,
	"remaining_uses"	integer,
	"inventory_item_id"	varchar(20) NOT NULL,
	FOREIGN KEY("inventory_item_id") REFERENCES "core_item_inventory"("inventory_item_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("inventory_item_id")
);
CREATE TABLE IF NOT EXISTS "core_borrow_info" (
	"borrow_id"	varchar(20) NOT NULL,
	"b_user_id"	varchar(20),
	"request_date"	datetime,
	"borrow_date"	date,
	"due_date"	date,
	"status"	varchar(1),
	"questions_responses"	text NOT NULL CHECK((JSON_VALID("questions_responses") OR "questions_responses" IS NULL)),
	"remarks"	varchar(45),
	"notification_sent"	bool NOT NULL,
	"approved_by_id"	varchar(20),
	"user_id"	varchar(20),
	"laboratory_id"	varchar(20) NOT NULL,
	FOREIGN KEY("approved_by_id") REFERENCES "core_user"("user_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("laboratory_id") REFERENCES "core_laboratory"("laboratory_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("user_id") REFERENCES "core_user"("user_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("borrow_id")
);
CREATE TABLE IF NOT EXISTS "core_workinprogress" (
	"wip_id"	varchar(20) NOT NULL,
	"start_time"	datetime NOT NULL,
	"end_time"	datetime,
	"description"	text NOT NULL,
	"status"	varchar(1) NOT NULL,
	"remarks"	text,
	"laboratory_id"	varchar(20) NOT NULL,
	"room_id"	varchar(20),
	"user_id"	varchar(20),
	FOREIGN KEY("user_id") REFERENCES "core_user"("user_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("laboratory_id") REFERENCES "core_laboratory"("laboratory_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("room_id") REFERENCES "core_rooms"("room_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("wip_id")
);
CREATE TABLE IF NOT EXISTS "core_item_inventory" (
	"inventory_item_id"	varchar(20) NOT NULL,
	"date_purchased"	datetime,
	"date_received"	datetime,
	"purchase_price"	real,
	"remarks"	varchar(45),
	"qty"	integer NOT NULL,
	"item_id"	varchar(20) NOT NULL,
	"supplier_id"	varchar(20),
	"uses"	integer NOT NULL,
	FOREIGN KEY("item_id") REFERENCES "core_item_description"("item_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("supplier_id") REFERENCES "core_suppliers"("suppliers_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("inventory_item_id")
);
CREATE TABLE IF NOT EXISTS "core_item_description" (
	"item_id"	varchar(20) NOT NULL,
	"item_name"	varchar(45),
	"alert_qty"	integer,
	"add_cols"	varchar(255),
	"is_disabled"	bool NOT NULL,
	"rec_per_inv"	bool NOT NULL,
	"allow_borrow"	bool NOT NULL,
	"is_consumable"	bool NOT NULL,
	"rec_expiration"	bool NOT NULL,
	"expiry_type"	varchar(45),
	"max_uses"	integer,
	"maintenance_interval"	integer,
	"qty_limit"	integer,
	"laboratory_id"	varchar(20),
	"itemType_id"	integer,
	"lead_time_prep"	integer NOT NULL,
	FOREIGN KEY("laboratory_id") REFERENCES "core_laboratory"("laboratory_id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("itemType_id") REFERENCES "core_item_types"("itemType_id") DEFERRABLE INITIALLY DEFERRED,
	PRIMARY KEY("item_id")
);
