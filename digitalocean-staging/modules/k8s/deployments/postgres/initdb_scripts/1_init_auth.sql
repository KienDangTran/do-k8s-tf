DROP SCHEMA IF EXISTS auth CASCADE;

CREATE SCHEMA IF NOT EXISTS auth;

SET search_path = "auth";

SET TIMEZONE TO +7;

----------------------------------------------------------------------------------------------------

CREATE SEQUENCE IF NOT EXISTS auth.token_blacklist_seq START 101;
DROP TABLE IF EXISTS auth.token_blacklist CASCADE;
CREATE TABLE IF NOT EXISTS auth.token_blacklist (
  id                 BIGINT       NOT NULL DEFAULT nextval('auth.token_blacklist_seq' :: REGCLASS),
  jti                VARCHAR(255) NOT NULL,
  username           VARCHAR(255) NOT NULL,
  ip                 VARCHAR(50),
  mac                VARCHAR(50),
  expires_in         BIGINT,
  blacklisted        BOOLEAN,

  version            BIGINT                DEFAULT 0,
  created_date       TIMESTAMP             DEFAULT CURRENT_TIMESTAMP,
  last_modified_date TIMESTAMP             DEFAULT CURRENT_TIMESTAMP,
  created_by         VARCHAR(255),
  last_modified_by   VARCHAR(255),

  PRIMARY KEY (id)
);

----------------------------------------------------------------------------------------------------
------------------------- authority ----------------------------------------------------------------

CREATE TYPE auth.AUTHORITY_STATUS_ENUM AS ENUM ('ACTIVE', 'SUSPENDED');
CREATE SEQUENCE IF NOT EXISTS auth.authority_seq START 101;
DROP TABLE IF EXISTS auth.authority CASCADE;
CREATE TABLE IF NOT EXISTS auth.authority (
  id                 INTEGER                    NOT NULL DEFAULT nextval('auth.authority_seq' :: REGCLASS),
  code               VARCHAR(255)               NOT NULL UNIQUE,
  status             auth.AUTHORITY_STATUS_ENUM NOT NULL DEFAULT 'ACTIVE' :: auth.AUTHORITY_STATUS_ENUM,

  version            BIGINT                              DEFAULT 0,
  created_date       TIMESTAMP                           DEFAULT CURRENT_TIMESTAMP,
  last_modified_date TIMESTAMP                           DEFAULT CURRENT_TIMESTAMP,
  created_by         VARCHAR(255),
  last_modified_by   VARCHAR(255),

  PRIMARY KEY (id)
);

-- auth
INSERT INTO auth.authority(code)
VALUES ('STAFF'),
       ('USER'),
       ('ROLE'),
       ('AUTHORITY'),
       -- lotte
       ('SCHEDULER'),
       ('ISSUE'),
       ('RULE'),
       ('PRIZE'),
       ('LOTTERY'),
       ('TICKET'),
       ('DRAW_RESULT'),
       -- accou
       ('ACCOUNT'),
       ('AGENT_LEVEL'),
       ('JOURNAL_ENTRY'),
       ('TURNOVER'),
       -- payme
       ('BANK'),
       ('CCY'),
       ('PAYMENT_CARD'),
       ('PAYMENT_METHOD'),
       ('PAYMENT_CHANNEL'),
       ('PAYMENT_VENDOR'),
       ('PROMOTION'),
       ('TX');

------------------------- roles --------------------------------------------------------------------
CREATE TYPE auth.ROLE_STATUS_ENUM AS ENUM ('ACTIVE', 'SUSPENDED');
CREATE SEQUENCE IF NOT EXISTS auth.role_seq START 101;
DROP TABLE IF EXISTS auth.role CASCADE;
CREATE TABLE IF NOT EXISTS auth.role (
  id                 INTEGER               NOT NULL DEFAULT nextval('auth.role_seq' :: REGCLASS),
  code               VARCHAR(255)          NOT NULL UNIQUE,
  parent_role_id     INTEGER,
  status             auth.ROLE_STATUS_ENUM NOT NULL DEFAULT 'ACTIVE' :: auth.ROLE_STATUS_ENUM,

  version            BIGINT                         DEFAULT 0,
  created_date       TIMESTAMP                      DEFAULT CURRENT_TIMESTAMP,
  last_modified_date TIMESTAMP                      DEFAULT CURRENT_TIMESTAMP,
  created_by         VARCHAR(255),
  last_modified_by   VARCHAR(255),

  PRIMARY KEY (id),
  FOREIGN KEY (parent_role_id) REFERENCES auth.role(id)
);

INSERT INTO auth.role(id, code)
VALUES (1, 'ROLE_ADMIN'),
       (2, 'ROLE_STAFF'),
       (3, 'ROLE_USER');

------------------------- role_authority -----------------------------------------------------------

CREATE SEQUENCE IF NOT EXISTS auth.role_authority_seq START 101;
DROP TABLE IF EXISTS auth.role_authority CASCADE;
CREATE TABLE IF NOT EXISTS auth.role_authority (
  id                 INTEGER NOT NULL DEFAULT nextval('auth.role_seq' :: REGCLASS),
  authority_id       INTEGER NOT NULL,
  role_id            INTEGER NOT NULL,
  read               BOOLEAN          DEFAULT TRUE,
  write              BOOLEAN          DEFAULT FALSE,
  exec               BOOLEAN          DEFAULT FALSE,

  version            BIGINT           DEFAULT 0,
  created_date       TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
  last_modified_date TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
  created_by         VARCHAR(255),
  last_modified_by   VARCHAR(255),

  PRIMARY KEY (id),
  FOREIGN KEY (role_id) REFERENCES auth.role(id),
  FOREIGN KEY (authority_id) REFERENCES auth.authority(id),
  UNIQUE (role_id, authority_id)
);

INSERT INTO auth.role_authority(authority_id, role_id, write, exec)
SELECT id, 1, TRUE, TRUE
FROM auth.authority;

------------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS auth.staff_seq START 101;
DROP TABLE IF EXISTS auth.staff CASCADE;
CREATE TABLE IF NOT EXISTS auth.staff (
  id                      BIGINT       NOT NULL DEFAULT nextval('auth.staff_seq' :: REGCLASS),
  username                VARCHAR(255) NOT NULL UNIQUE,
  password                VARCHAR(255) NOT NULL,
  fullname                VARCHAR(255) NOT NULL,
  email                   VARCHAR(255) NOT NULL UNIQUE,
  phone                   VARCHAR(50) UNIQUE,
  date_of_birth           DATE,
  enabled                 BOOLEAN      NOT NULL DEFAULT TRUE,
  account_non_locked      BOOLEAN      NOT NULL DEFAULT TRUE,
  account_non_expired     BOOLEAN      NOT NULL DEFAULT TRUE,
  credentials_non_expired BOOLEAN      NOT NULL DEFAULT TRUE,

  version                 BIGINT                DEFAULT 0,
  created_date            TIMESTAMP             DEFAULT CURRENT_TIMESTAMP,
  last_modified_date      TIMESTAMP             DEFAULT CURRENT_TIMESTAMP,
  created_by              VARCHAR(255),
  last_modified_by        VARCHAR(255),

  PRIMARY KEY (id)
);

INSERT INTO auth.staff(id, username, password, fullname, email, enabled)
VALUES (1,
        'admin',
        '{bcrypt}$2a$10$EOs8VROb14e7ZnydvXECA.4LoIhPOoFHKvVF/iBZ/ker17Eocz4Vi',
        'Administrator',
        'admin@evil.com',
        TRUE);

----------------------------------------------------------------------------------------------------

CREATE SEQUENCE IF NOT EXISTS auth.staff_role_seq START 101;
DROP TABLE IF EXISTS auth.staff_role CASCADE;
CREATE TABLE IF NOT EXISTS auth.staff_role (
  id                 INTEGER NOT NULL DEFAULT nextval('auth.staff_role_seq' :: REGCLASS),
  role_id            INTEGER NOT NULL DEFAULT 1,
  staff_id           BIGINT  NOT NULL,

  version            BIGINT           DEFAULT 0,
  created_date       TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
  last_modified_date TIMESTAMP        DEFAULT CURRENT_TIMESTAMP,
  created_by         VARCHAR(255),
  last_modified_by   VARCHAR(255),

  PRIMARY KEY (id),
  FOREIGN KEY (role_id) REFERENCES auth.role(id),
  FOREIGN KEY (staff_id) REFERENCES auth.staff(id),
  UNIQUE (staff_id, role_id)
);

INSERT INTO auth.staff_role(staff_id, role_id)
VALUES (1, 1);

----------------------------------------------------------------------------------------------------

CREATE SEQUENCE IF NOT EXISTS auth.user_seq START 101;
DROP TABLE IF EXISTS auth."user" CASCADE;
CREATE TABLE IF NOT EXISTS auth."user" (
  id                      BIGINT       NOT NULL DEFAULT nextval('auth.user_seq' :: REGCLASS),
  username                VARCHAR(255) NOT NULL UNIQUE,
  password                VARCHAR(255) NOT NULL,
  fullname                VARCHAR(255) NOT NULL,
  firebase_uid            VARCHAR(50) UNIQUE,
  email                   VARCHAR(255) NOT NULL UNIQUE,
  phone                   VARCHAR(50) UNIQUE,
  date_of_birth           DATE,
  enabled                 BOOLEAN      NOT NULL DEFAULT TRUE,
  account_non_locked      BOOLEAN      NOT NULL DEFAULT TRUE,
  account_non_expired     BOOLEAN      NOT NULL DEFAULT TRUE,
  credentials_non_expired BOOLEAN      NOT NULL DEFAULT TRUE,
  referral_link           VARCHAR(255),

  version                 BIGINT                DEFAULT 0,
  created_date            TIMESTAMP             DEFAULT CURRENT_TIMESTAMP,
  last_modified_date      TIMESTAMP             DEFAULT CURRENT_TIMESTAMP,
  created_by              VARCHAR(255),
  last_modified_by        VARCHAR(255),

  PRIMARY KEY (id)
);

INSERT INTO auth."user"(id, username, password, fullname, phone, email)
VALUES (1,
        'root',
        '{bcrypt}$2a$10$EOs8VROb14e7ZnydvXECA.4LoIhPOoFHKvVF/iBZ/ker17Eocz4Vi',
        'ROOT',
        '09056843152',
        'root@evil.com');

------------------------------------------------------------------------------------------------------------------------

CREATE TYPE auth.DOCUMENT_TYPE_ENUM AS ENUM ('ID_CARD', 'PASSPORT');

CREATE TYPE auth.DOCUMENT_STATUS_ENUM AS ENUM ('ACTIVE', 'SUSPENDED');
CREATE SEQUENCE IF NOT EXISTS auth.user_document_seq START 101;
DROP TABLE IF EXISTS auth.user_document CASCADE;
CREATE TABLE IF NOT EXISTS auth.user_document (
  id                 INTEGER                 NOT NULL DEFAULT nextval('auth.user_document_seq' :: REGCLASS),
  user_id            BIGINT                  NOT NULL,
  card_no            VARCHAR(255)            NOT NULL,
  type               auth.DOCUMENT_TYPE_ENUM NOT NULL,
  image_url          TEXT,
  issue_date         DATE,
  expire_date        DATE,
  status             auth.DOCUMENT_STATUS_ENUM        DEFAULT 'ACTIVE' :: auth.DOCUMENT_STATUS_ENUM,

  version            BIGINT                           DEFAULT 0,
  created_date       TIMESTAMP                        DEFAULT CURRENT_TIMESTAMP,
  last_modified_date TIMESTAMP                        DEFAULT CURRENT_TIMESTAMP,
  created_by         VARCHAR(255),
  last_modified_by   VARCHAR(255),

  PRIMARY KEY (id),
  FOREIGN KEY (user_id) REFERENCES auth."user"(id),
  UNIQUE (card_no, type)
);