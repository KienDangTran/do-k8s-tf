DROP SCHEMA IF EXISTS account CASCADE;

CREATE SCHEMA IF NOT EXISTS account;

SET search_path = account;

SET TIMEZONE TO +7;

------------------------------------------------------------------------------------------------------------------------

CREATE TYPE account.ACCOUNT_CATEGORY_ENUM AS ENUM (
  'COMPANY_ASSET',
  'COMPANY_EQUITY',
  'COMPANY_LIABILITY',
  'COMPANY_REVENUE',
  'COMPANY_EXPENSE',
  'USER_ASSET'
  );

CREATE TYPE account.GAME_CATEGORY_ENUM AS ENUM ('LOTTERY', 'SPORT', 'CASINO');

CREATE TYPE account.NORMAL_BALANCE_ENUM AS ENUM ('DR', 'CR');

DROP TYPE IF EXISTS account.JOURNAL_ENUM;
CREATE TYPE account.JOURNAL_ENUM AS ENUM (
  'INVESTMENT',
  'DEPOSIT',
  'WITHDRAWAL',
  'BET',
  'BET_USING_BONUS',
  'DECREASING_ADJUSTMENT',
  'INCREASING_ADJUSTMENT',
  'PAYOUT',
  'COMMISSION',
  'BONUS',
  'CANCEL_BONUS'
  );

CREATE TYPE account.ADJUST_TYPE_ENUM AS ENUM ('AMT', 'PERCENT');

------------------------------------------------------------------------------------------------------------------------

CREATE SEQUENCE account.turnover_seq START 101;
DROP TABLE IF EXISTS account.turnover CASCADE;
CREATE TABLE IF NOT EXISTS account.turnover (
  id                 INTEGER                    NOT NULL DEFAULT nextval('account.turnover_seq' :: REGCLASS),
  journal            account.JOURNAL_ENUM       NOT NULL,
  game_category      account.GAME_CATEGORY_ENUM NOT NULL,
  ccy                VARCHAR(5)                 NOT NULL,
  turnover_factor    NUMERIC(5, 2)                       DEFAULT 0,

  version            BIGINT                              DEFAULT 0,
  created_date       TIMESTAMP                           DEFAULT CURRENT_TIMESTAMP,
  last_modified_date TIMESTAMP                           DEFAULT CURRENT_TIMESTAMP,
  created_by         VARCHAR(255),
  last_modified_by   VARCHAR(255),

  PRIMARY KEY (id),
  UNIQUE (journal, game_category, ccy),
  CHECK (turnover_factor != 0)
);

INSERT INTO account.turnover(id, game_category, journal, ccy, turnover_factor)
VALUES (1, 'LOTTERY', 'DEPOSIT', 'VND', 1),
       (2, 'LOTTERY', 'BONUS', 'VND', 1),
       (4, 'SPORT', 'DEPOSIT', 'VND', 1),
       (5, 'SPORT', 'BONUS', 'VND', 1),
       (7, 'CASINO', 'DEPOSIT', 'VND', 1),
       (8, 'CASINO', 'BONUS', 'VND', 1);

------------------------------------------------------------------------------------------------------------------------

CREATE SEQUENCE IF NOT EXISTS account.agent_level_seq START 101;
DROP TABLE IF EXISTS account.agent_level CASCADE;
CREATE TABLE account.agent_level (
  id                 INTEGER      NOT NULL DEFAULT nextval('account.agent_level_seq' :: REGCLASS),
  code               VARCHAR(255) NOT NULL UNIQUE,
  superior_level_id  INTEGER,
  min_required_user  INTEGER      NOT NULL,

  version            BIGINT                DEFAULT 0,
  created_date       TIMESTAMP             DEFAULT CURRENT_TIMESTAMP,
  last_modified_date TIMESTAMP             DEFAULT CURRENT_TIMESTAMP,
  created_by         VARCHAR(255),
  last_modified_by   VARCHAR(255),

  PRIMARY KEY (id),
  FOREIGN KEY (superior_level_id) REFERENCES account.agent_level(id)
);

INSERT INTO account.agent_level(id, code, superior_level_id, min_required_user)
VALUES (1, 'LEVEL_1', NULL, 5),
       (2, 'LEVEL_2', 1, 5),
       (3, 'LEVEL_3', 1, 5),
       (4, 'LEVEL_4', 1, 5),
       (5, 'LEVEL_5', 1, 5);

------------------------------------------------------------------------------------------------------------------------

CREATE SEQUENCE IF NOT EXISTS account.commission_seq START 101;
DROP TABLE IF EXISTS account.commission CASCADE;
CREATE TABLE account.commission (
  id                   INTEGER        NOT NULL DEFAULT nextval('account.commission_seq' :: REGCLASS),
  agent_level_id       INTEGER        NOT NULL,
  company_revenue_from NUMERIC(30, 2) NOT NULL,
  company_revenue_to   NUMERIC(30, 2),
  rate                 NUMERIC(30, 2) NOT NULL,

  version              BIGINT                  DEFAULT 0,
  created_date         TIMESTAMP               DEFAULT CURRENT_TIMESTAMP,
  last_modified_date   TIMESTAMP               DEFAULT CURRENT_TIMESTAMP,
  created_by           VARCHAR(255),
  last_modified_by     VARCHAR(255),

  PRIMARY KEY (id),
  FOREIGN KEY (agent_level_id) REFERENCES account.agent_level(id),
  UNIQUE (agent_level_id, company_revenue_from, company_revenue_to),
  CHECK (company_revenue_from >= 0 AND company_revenue_to > company_revenue_from AND rate >= 0)
);

INSERT INTO account.commission(id, agent_level_id, company_revenue_from, company_revenue_to, rate)
VALUES (1, 1, 1000000, 200000000, 30),
       (2, 2, 1000000, 200000000, 30),
       (3, 3, 1000000, 200000000, 30),
       (4, 4, 1000000, 200000000, 30),
       (5, 5, 1000000, 200000000, 30),
       (6, 1, 200000001, 2000000000, 35),
       (7, 2, 200000001, 2000000000, 35),
       (8, 3, 200000001, 2000000000, 35),
       (9, 4, 200000001, 2000000000, 35),
       (10, 5, 200000001, 2000000000, 35),
       (11, 1, 2000000001, NULL, 45),
       (12, 2, 2000000001, NULL, 45),
       (13, 3, 2000000001, NULL, 45),
       (14, 4, 2000000001, NULL, 45),
       (15, 5, 2000000001, NULL, 45);
------------------------------------------------------------------------------------------------------------------------

CREATE TYPE account.ACCOUNT_STATUS_ENUM AS ENUM ('ACTIVE', 'LOCKED', 'SUSPENDED');

CREATE SEQUENCE IF NOT EXISTS account.account_seq START 101;
DROP TABLE IF EXISTS account.account CASCADE;
CREATE TABLE IF NOT EXISTS account.account (
  id                  BIGINT                        NOT NULL DEFAULT nextval('account.account_seq' :: REGCLASS),
  username            VARCHAR(255)                  NOT NULL,
  category            account.ACCOUNT_CATEGORY_ENUM NOT NULL,
  account_name        VARCHAR(255),
  superior_account_id BIGINT                                 DEFAULT 1,
  agent_level_id      INTEGER,
  status              account.ACCOUNT_STATUS_ENUM   NOT NULL DEFAULT 'ACTIVE' :: account.ACCOUNT_STATUS_ENUM,

  version             BIGINT                                 DEFAULT 0,
  created_date        TIMESTAMP                              DEFAULT CURRENT_TIMESTAMP,
  last_modified_date  TIMESTAMP                              DEFAULT CURRENT_TIMESTAMP,
  created_by          VARCHAR(255),
  last_modified_by    VARCHAR(255),

  PRIMARY KEY (id),
  UNIQUE (username, category),
  FOREIGN KEY (superior_account_id) REFERENCES account.account(id),
  FOREIGN KEY (agent_level_id) REFERENCES account.agent_level(id)
);

INSERT INTO account.account(id, username, category, account_name)
VALUES (1, 'root', 'COMPANY_ASSET', 'TK TIỀN'),
       (2, 'root', 'COMPANY_EQUITY', 'TK VỐN ĐẦU TƯ'),
       (3, 'root', 'COMPANY_LIABILITY', 'TK CÔNG NỢ'),
       (4, 'root', 'COMPANY_REVENUE', 'TK KINH DOANH'),
       (5, 'root', 'COMPANY_EXPENSE', 'TK CHI PHÍ');

------------------------------------------------------------------------------------------------------------------------

CREATE SEQUENCE IF NOT EXISTS account.balance_seq START 101;
DROP TABLE IF EXISTS account.balance CASCADE;
CREATE TABLE IF NOT EXISTS account.balance (
  id                 BIGINT         NOT NULL DEFAULT nextval('account.balance_seq' :: REGCLASS),
  account_id         BIGINT         NOT NULL,
  game_category      account.GAME_CATEGORY_ENUM,
  ccy                VARCHAR(5)     NOT NULL,
  withdraw_limit     INTEGER                 DEFAULT 5,
  balance            NUMERIC(30, 2) NOT NULL DEFAULT 0,
  bonus_balance      NUMERIC(30, 2) NOT NULL DEFAULT 0,
  turnover_amt       NUMERIC(30, 2)          DEFAULT 0,
  total_betting_amt  NUMERIC(30, 2)          DEFAULT 0,
  total_payout       NUMERIC(30, 2)          DEFAULT 0,

  version            BIGINT                  DEFAULT 0,
  created_date       TIMESTAMP               DEFAULT CURRENT_TIMESTAMP,
  last_modified_date TIMESTAMP               DEFAULT CURRENT_TIMESTAMP,
  created_by         VARCHAR(255),
  last_modified_by   VARCHAR(255),

  PRIMARY KEY (id),
  FOREIGN KEY (account_id) REFERENCES account.account(id),
  UNIQUE (account_id, ccy, game_category),
  CHECK (
      bonus_balance >= 0
      AND withdraw_limit > 0
      AND total_betting_amt >= 0
      AND turnover_amt >= 0
    )
);

INSERT INTO account.balance(id, account_id, ccy, game_category)
VALUES (1, 1, 'VND', NULL),
       (2, 2, 'VND', NULL),
       (3, 3, 'VND', NULL),
       (4, 4, 'VND', NULL),
       (5, 5, 'VND', NULL);

------------------------------------------------------------------------------------------------------------------------

CREATE TYPE account.PROMOTION_STATUS_ENUM AS ENUM ('NEW', 'APPLYING', 'ENDED');
CREATE SEQUENCE IF NOT EXISTS account.promotion_seq START 101;
DROP TABLE IF EXISTS account.promotion CASCADE;
CREATE TABLE IF NOT EXISTS account.promotion (
  id                 INTEGER                    NOT NULL DEFAULT nextval('account.promotion_seq' :: REGCLASS),
  code               VARCHAR(255)               NOT NULL UNIQUE,
  adjust_type        account.ADJUST_TYPE_ENUM   NOT NULL DEFAULT 'AMT' :: account.ADJUST_TYPE_ENUM,
  auto_apply         BOOLEAN                             DEFAULT FALSE,
  journal            VARCHAR(50)                NOT NULL,
  ccy                VARCHAR(5)                 NOT NULL,
  game_category      account.GAME_CATEGORY_ENUM NOT NULL,
  description        TEXT,
  bonus_value        NUMERIC(30, 2)             NOT NULL DEFAULT 0,
  turnover_factor    NUMERIC(5, 2),
  max_apply_time     INTEGER                    NOT NULL DEFAULT 1,
  start_time         TIMESTAMP                  NOT NULL,
  end_time           TIMESTAMP,
  expire_in          BIGINT,
  status             account.PROMOTION_STATUS_ENUM       DEFAULT 'NEW' :: account.PROMOTION_STATUS_ENUM,

  version            BIGINT                              DEFAULT 0,
  created_date       TIMESTAMP                           DEFAULT CURRENT_TIMESTAMP,
  last_modified_date TIMESTAMP                           DEFAULT CURRENT_TIMESTAMP,
  created_by         VARCHAR(255),
  last_modified_by   VARCHAR(255),

  PRIMARY KEY (id),
  CHECK (bonus_value > 0 AND turnover_factor != 0 AND max_apply_time > 0)
);

------------------------------------------------------------------------------------------------------------------------

CREATE SEQUENCE IF NOT EXISTS account.bonus_record_seq START 101;
DROP TABLE IF EXISTS account.bonus_record CASCADE;
CREATE TABLE IF NOT EXISTS account.bonus_record (
  id                 BIGINT         NOT NULL DEFAULT nextval('account.bonus_record_seq' :: REGCLASS),
  balance_id         BIGINT         NOT NULL,
  promotion_id       INTEGER        NOT NULL,
  applied_count      INTEGER        NOT NULL DEFAULT 0,
  bonus_amt          NUMERIC(30, 2) NOT NULL DEFAULT 0,

  version            BIGINT                  DEFAULT 0,
  created_date       TIMESTAMP               DEFAULT CURRENT_TIMESTAMP,
  last_modified_date TIMESTAMP               DEFAULT CURRENT_TIMESTAMP,
  created_by         VARCHAR(255),
  last_modified_by   VARCHAR(255),

  PRIMARY KEY (id),
  FOREIGN KEY (balance_id) REFERENCES account.balance(id),
  FOREIGN KEY (promotion_id) REFERENCES account.promotion(id),
  UNIQUE (balance_id, promotion_id),
  CHECK (promotion_id >= 0 AND applied_count >= 0 AND bonus_amt >= 0)
);

------------------------------------------------------------------------------------------------------------------------

CREATE SEQUENCE IF NOT EXISTS account.journal_entry_seq START 101;
DROP TABLE IF EXISTS account.journal_entry CASCADE;
CREATE TABLE IF NOT EXISTS account.journal_entry (
  id                  BIGINT               NOT NULL DEFAULT nextval('account.journal_entry_seq' :: REGCLASS),
  balance_id          BIGINT               NOT NULL,
  journal             account.JOURNAL_ENUM NOT NULL,
  prior_balance       NUMERIC(30, 2)       NOT NULL DEFAULT 0,
  prior_bonus_balance NUMERIC(30, 2)       NOT NULL DEFAULT 0,
  dr_amt              NUMERIC(30, 2)       NOT NULL DEFAULT 0,
  cr_amt              NUMERIC(30, 2)       NOT NULL DEFAULT 0,
  ref_id              BIGINT               NOT NULL,
  ref_type            VARCHAR(255)         NOT NULL,

  version             BIGINT                        DEFAULT 0,
  created_date        TIMESTAMP                     DEFAULT CURRENT_TIMESTAMP,
  last_modified_date  TIMESTAMP                     DEFAULT CURRENT_TIMESTAMP,
  created_by          VARCHAR(255),
  last_modified_by    VARCHAR(255),

  PRIMARY KEY (id),
  FOREIGN KEY (balance_id) REFERENCES account.balance(id),
  UNIQUE (balance_id, journal, ref_id, ref_type),
  CHECK (dr_amt >= 0 AND cr_amt >= 0)
);

------------------------------------------------------------------------------------------------------------------------

CREATE SEQUENCE IF NOT EXISTS account.in_progress_journal_seq START 101;
DROP TABLE IF EXISTS account.in_progress_journal CASCADE;
CREATE TABLE IF NOT EXISTS account.in_progress_journal (
  id                 BIGINT               NOT NULL DEFAULT nextval('account.in_progress_journal_seq' :: REGCLASS),
  balance_id         BIGINT               NOT NULL,
  journal            account.JOURNAL_ENUM NOT NULL,
  amt                NUMERIC(30, 2)       NOT NULL DEFAULT 0,
  ref_id             BIGINT               NOT NULL,
  ref_type           VARCHAR(255)         NOT NULL,

  version            BIGINT                        DEFAULT 0,
  created_date       TIMESTAMP                     DEFAULT CURRENT_TIMESTAMP,
  last_modified_date TIMESTAMP                     DEFAULT CURRENT_TIMESTAMP,
  created_by         VARCHAR(255),
  last_modified_by   VARCHAR(255),

  PRIMARY KEY (id),
  FOREIGN KEY (balance_id) REFERENCES account.balance(id),
  UNIQUE (balance_id, journal, ref_id, ref_type),
  CHECK ( amt > 0 )
);

------------------------------------------------------------------------------------------------------------------------
