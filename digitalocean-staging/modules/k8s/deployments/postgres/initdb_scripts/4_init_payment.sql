DROP SCHEMA IF EXISTS payment CASCADE;

CREATE SCHEMA payment;

SET search_path = "payment";

SET TIMEZONE TO +7;

------------------------------------------------------------------------------------------------------------------------

CREATE TYPE payment.BANK_TYPE_ENUM AS ENUM ('LOCAL_BANK', 'GLOBAL_BANK', 'E_WALLET');

CREATE TYPE payment.PAYMENT_CARD_TYPE_ENUM AS ENUM ('ATM', 'DEBIT', 'CREDIT');

CREATE TYPE payment.CCY_ENUM AS ENUM ('VND', 'CNY', 'USD', 'THB', 'BTC', 'ETH');

------------------------------------------------------------------------------------------------------------------------

CREATE TYPE payment.PAYMENT_VENDOR_STATUS_ENUM AS ENUM ('ACTIVE', 'SUSPENDED');
CREATE SEQUENCE IF NOT EXISTS payment.payment_vendor_seq START 101;
DROP TABLE IF EXISTS payment.payment_vendor CASCADE;
CREATE TABLE IF NOT EXISTS payment.payment_vendor (
  id                 INTEGER     NOT NULL               DEFAULT nextval('payment.payment_vendor_seq' :: REGCLASS),
  code               VARCHAR(50) NOT NULL UNIQUE,
  deposit_uri        TEXT        NOT NULL,
  withdrawal_uri     TEXT        NOT NULL,
  status             payment.PAYMENT_VENDOR_STATUS_ENUM DEFAULT 'SUSPENDED' :: payment.PAYMENT_VENDOR_STATUS_ENUM,

  version            BIGINT                             DEFAULT 0,
  created_date       TIMESTAMP                          DEFAULT CURRENT_TIMESTAMP,
  last_modified_date TIMESTAMP                          DEFAULT CURRENT_TIMESTAMP,
  created_by         VARCHAR(255),
  last_modified_by   VARCHAR(255),

  PRIMARY KEY (id)
);

INSERT INTO payment.payment_vendor(id, code, deposit_uri, withdrawal_uri, status)
VALUES (1, 'NGAN_LUONG', 'https://sandbox.nganluong.vn:8088/nl30/checkout.api.nganluong.post.php',
        'https://sandbox.nganluong.vn:8088/nl35/withdraw.api.post.php', 'ACTIVE'),
       (2, 'HELP_2_PAY', '', '', 'SUSPENDED');

------------------------------------------------------------------------------------------------------------------------

CREATE SEQUENCE IF NOT EXISTS payment.vendor_api_param_seq START 101;
DROP TABLE IF EXISTS payment.vendor_api_param CASCADE;
CREATE TABLE IF NOT EXISTS payment.vendor_api_param (
  id                 INTEGER      NOT NULL DEFAULT nextval('payment.vendor_api_param_seq' :: REGCLASS),
  payment_vendor_id  INTEGER      NOT NULL,
  key                VARCHAR(255) NOT NULL,
  default_value      TEXT,
  required           BOOLEAN,
  description        TEXT,

  version            BIGINT                DEFAULT 0,
  created_date       TIMESTAMP             DEFAULT CURRENT_TIMESTAMP,
  last_modified_date TIMESTAMP             DEFAULT CURRENT_TIMESTAMP,
  created_by         VARCHAR(255),
  last_modified_by   VARCHAR(255),

  PRIMARY KEY (id),
  FOREIGN KEY (payment_vendor_id) REFERENCES payment.payment_vendor(id),
  UNIQUE (payment_vendor_id, key)
);

INSERT INTO payment.vendor_api_param(id,
                                     payment_vendor_id,
                                     key,
                                     default_value,
                                     required,
                                     description)
VALUES (1,
        1,
        'merchant_id',
        '30439',
        TRUE,
        'website/merchant code registered on nganluong(ID connection)'),
       (2, 1, 'merchant_password', '034cdf00b48ea2ba265880b9e357f62b', TRUE, 'MD5(MerchantPass).'),
       (3, 1, 'receiver_email', 'nguyencamhue@gmail.com',
        TRUE,
        'Email address of NganLuong.vn account that uses to receive money from the payment'),
       (4, 1, 'return_url', 'https://www.staging.3bwins.com/txSuccess',
        FALSE,
        'Payment Succeeded Page URL . when buyer pay successfully, it’ll redirect this link'),
       (5,
        1,
        'cancel_url',
        'https://www.staging.3bwins.com/txCancel',
        FALSE,
        'Payment Canceled Page URL.  when buyer don’t pay and click “cancel payment”, it’ll redirect this link'),
       (6,
        1,
        'time_limit',
        NULL,
        FALSE,
        'Payment Pending Duration (by minutes); Default = 1440 minutes (24 hours)');
------------------------------------------------------------------------------------------------------------------------

CREATE TYPE payment.BANK_STATUS_ENUM AS ENUM ('ACTIVE', 'SUSPENDED');
CREATE SEQUENCE IF NOT EXISTS payment.bank_seq START 101;
DROP TABLE IF EXISTS payment.bank CASCADE;
CREATE TABLE IF NOT EXISTS payment.bank (
  id                 INTEGER                NOT NULL DEFAULT nextval('payment.bank_seq' :: REGCLASS),
  code               VARCHAR(50)            NOT NULL UNIQUE,
  name               VARCHAR(255),
  logo_url           TEXT,
  type               payment.BANK_TYPE_ENUM NOT NULL,
  status             payment.BANK_STATUS_ENUM        DEFAULT 'ACTIVE' :: payment.BANK_STATUS_ENUM,

  version            BIGINT                          DEFAULT 0,
  created_date       TIMESTAMP                       DEFAULT CURRENT_TIMESTAMP,
  last_modified_date TIMESTAMP                       DEFAULT CURRENT_TIMESTAMP,
  created_by         VARCHAR(255),
  last_modified_by   VARCHAR(255),

  PRIMARY KEY (id)
);
INSERT INTO payment.bank(id, code, type, name)
VALUES (1, 'VCB', 'LOCAL_BANK', 'Ngân hàng TMCP Ngoại Thương Việt Nam (Vietcombank)'),
       (2, 'DAB', 'LOCAL_BANK', 'Ngân hàng TMCP Đông Á (DongA Bank)'),
       (3, 'TCB', 'LOCAL_BANK', 'Ngân hàng TMCP Kỹ Thương (Techcombank)'),
       (4, 'MB', 'LOCAL_BANK', 'Ngân hàng TMCP Quân Đội (MB)'),
       (5, 'VIB', 'LOCAL_BANK', 'Ngân hàng TMCP Quốc tế (VIB)'),
       (6, 'ICB', 'LOCAL_BANK', 'Ngân hàng TMCP Công Thương (VietinBank)'),
       (7, 'EXB', 'LOCAL_BANK', 'Ngân hàng TMCP Xuất Nhập Khẩu (Eximbank)'),
       (8, 'ACB', 'LOCAL_BANK', 'Ngân hàng TMCP Á Châu (ACB)'),
       (9, 'HDB', 'LOCAL_BANK', 'Ngân hàng TMCP Phát Triển Nhà TP. Hồ Chí Minh (HDBank)'),
       (10, 'MSB', 'LOCAL_BANK', 'Ngân hàng TMCP Hàng Hải (MariTimeBank)'),
       (11, 'NVB', 'LOCAL_BANK', 'Ngân hàng TMCP Quốc dân (NaviBank)'),
       (12, 'VAB', 'LOCAL_BANK', 'Ngân hàng TMCP Việt Á (VietA Bank)'),
       (13, 'VPB', 'LOCAL_BANK', 'Ngân hàng TMCP Việt Nam Thịnh Vượng  (VPBank)'),
       (14, 'STB', 'LOCAL_BANK', 'Ngân hàng TMCP Sài Gòn Thương Tín (Sacombank)'),
       (15, 'BAB', 'LOCAL_BANK', 'Ngân hàng TMCP Bắc Á'),
       (16, 'GPB', 'LOCAL_BANK', 'Ngân hàng TMCP Dầu Khí (GPBank)'),
       (17, 'AGB', 'LOCAL_BANK', 'Ngân hàng Nông nghiệp và Phát triển Nông thôn (Agribank)'),
       (18, 'BIDV', 'LOCAL_BANK', 'Ngân hàng Đầu tư và Phát triển Việt Nam (BIDV)'),
       (19, 'OJB', 'LOCAL_BANK', 'Ngân hàng TMCP Đại Dương (OceanBank)'),
       (20, 'PGB', 'LOCAL_BANK', 'Ngân Hàng TMCP Xăng Dầu Petrolimex (PGBank)'),
       (21, 'SHB', 'LOCAL_BANK', 'Ngân hàng TMCP Sài Gòn - Hà Nội (SHB)'),
       (22, 'TPB', 'LOCAL_BANK', 'Ngân hàng TMCP Tiên Phong (TienPhong Bank)'),
       (23, 'NAB', 'LOCAL_BANK', 'Ngân hàng Nam Á'),
       (24, 'SGB', 'LOCAL_BANK', 'Ngân hàng Sài Gòn Công Thương'),
       (25, 'ABB', 'LOCAL_BANK', 'Ngân hàng TMCP An Bình'),
       (26, 'SGCB', 'LOCAL_BANK', 'Ngân hàng Thương Mại Cổ Phần Sài Gòn - Saigon Commercial Bank'),
       (27, 'IVB', 'LOCAL_BANK', 'Ngân hàng trách nhiệm hữu hạn Indovina'),
       (28, 'GDB', 'LOCAL_BANK', 'Ngân hàng TMCP Bản Việt'),
       (29, 'WCP', 'E_WALLET', 'WeChat Pay'),
       (30, 'VIETTELPOST', 'LOCAL_BANK', 'Viettel post'),
       (31, 'VISA', 'GLOBAL_BANK', 'VISA'),
       (32, 'MASTER', 'GLOBAL_BANK', 'MASTER CARD'),
       (33, 'JCB', 'GLOBAL_BANK', 'JCB');

------------------------------------------------------------------------------------------------------------------------

CREATE TYPE payment.PAYMENT_METHOD_STATUS_ENUM AS ENUM ('ACTIVE', 'SUSPENDED');
CREATE SEQUENCE IF NOT EXISTS payment.payment_method_seq START 101;
DROP TABLE IF EXISTS payment.payment_method CASCADE;
CREATE TABLE IF NOT EXISTS payment.payment_method (
  id                 INTEGER     NOT NULL               DEFAULT nextval('payment.payment_method_seq' :: REGCLASS),
  code               VARCHAR(50) NOT NULL UNIQUE,
  name               VARCHAR(255),
  status             payment.PAYMENT_METHOD_STATUS_ENUM DEFAULT 'ACTIVE' :: payment.PAYMENT_METHOD_STATUS_ENUM,

  version            BIGINT                             DEFAULT 0,
  created_date       TIMESTAMP                          DEFAULT CURRENT_TIMESTAMP,
  last_modified_date TIMESTAMP                          DEFAULT CURRENT_TIMESTAMP,
  created_by         VARCHAR(255),
  last_modified_by   VARCHAR(255),

  PRIMARY KEY (id)
);

INSERT INTO payment.payment_method(id, code, name)
VALUES (1, 'NL', 'Thanh toán qua số dư ví Ngân Lượng'),
       (2, 'VISA', 'Thanh toán bằng thẻ Visa, Master Card'),
       (3, 'CREDIT_CARD_PREPAID', 'Thanh toán bằng thẻ visa, master trả trước'),
       (4, 'ATM_ONLINE', 'Thanh toán online dùng thẻ ATM/Tài khoản ngân hàng trong nước'),
       (5, 'ATM_OFFLINE', 'Thanh toán chuyển khoản tại cây ATM'),
       (6, 'NH_OFFLINE', 'Thanh toán chuyển khoản hoặc nộp tiền tại quầy giao dịch NH'),
       (7, 'IB_ONLINE', 'Thanh toán bằng internet banking'),
       (8, 'QRCODE', 'Thanh toán bằng việc quét mã QRCODE'),
       (9, 'CASH_IN_SHOP', 'Thanh toán tại quầy ViettelPost');

------------------------------------------------------------------------------------------------------------------------

CREATE SEQUENCE IF NOT EXISTS payment.payment_channel_seq START 501;
DROP TABLE IF EXISTS payment.payment_channel CASCADE;
CREATE TABLE IF NOT EXISTS payment.payment_channel (
  id                    INTEGER          NOT NULL DEFAULT nextval('payment.payment_channel_seq' :: REGCLASS),
  payment_vendor_id     INTEGER          NOT NULL,
  payment_method_id     INTEGER          NOT NULL,
  bank_id               INTEGER          NOT NULL,
  ccy                   payment.CCY_ENUM NOT NULL,
  min_amt               NUMERIC(30, 2)   NOT NULL DEFAULT 0,
  max_amt               NUMERIC(30, 2),
  required_card_type    payment.PAYMENT_CARD_TYPE_ENUM,
  bank_account_required BOOLEAN                   DEFAULT FALSE,
  deposit               BOOLEAN                   DEFAULT TRUE,
  withdrawal            BOOLEAN                   DEFAULT FALSE,
  auto_approve          BOOLEAN                   DEFAULT FALSE,

  version               BIGINT                    DEFAULT 0,
  created_date          TIMESTAMP                 DEFAULT CURRENT_TIMESTAMP,
  last_modified_date    TIMESTAMP                 DEFAULT CURRENT_TIMESTAMP,
  created_by            VARCHAR(255),
  last_modified_by      VARCHAR(255),

  PRIMARY KEY (id),
  FOREIGN KEY (payment_vendor_id) REFERENCES payment.payment_vendor(id),
  FOREIGN KEY (payment_method_id) REFERENCES payment.payment_method(id),
  FOREIGN KEY (bank_id) REFERENCES payment.bank(id),
  UNIQUE (payment_vendor_id, payment_method_id, bank_id),
  CHECK (min_amt >= 0 AND max_amt >= min_amt)
);

INSERT INTO payment.payment_channel(id,
                                    payment_vendor_id,
                                    payment_method_id,
                                    bank_id,
                                    ccy,
                                    min_amt,
                                    max_amt,
                                    required_card_type,
                                    bank_account_required,
                                    deposit,
                                    withdrawal)
VALUES
  -- 1. NL
  (1, 1, 1, 1, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (2, 1, 1, 2, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (3, 1, 1, 3, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (4, 1, 1, 4, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (5, 1, 1, 5, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (6, 1, 1, 6, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (7, 1, 1, 7, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (8, 1, 1, 8, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (9, 1, 1, 9, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (10, 1, 1, 10, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (11, 1, 1, 11, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (12, 1, 1, 12, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (13, 1, 1, 13, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (14, 1, 1, 14, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (15, 1, 1, 15, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (16, 1, 1, 16, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (17, 1, 1, 17, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (18, 1, 1, 18, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (19, 1, 1, 19, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (20, 1, 1, 20, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (21, 1, 1, 21, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (22, 1, 1, 22, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (23, 1, 1, 23, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (24, 1, 1, 24, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (25, 1, 1, 25, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (26, 1, 1, 26, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (27, 1, 1, 27, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (28, 1, 1, 28, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (29, 1, 1, 29, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  -- 2. VISA
  (30, 1, 2, 31, 'VND', 200000, 100000000, 'CREDIT', FALSE, TRUE, FALSE),
  (31, 1, 2, 32, 'VND', 200000, 100000000, 'CREDIT', FALSE, TRUE, FALSE),
  (32, 1, 2, 33, 'VND', 200000, 100000000, 'CREDIT', FALSE, TRUE, FALSE),
  -- 3. CREDIT_CARD_PREPAID
  (33, 1, 3, 31, 'VND', 200000, 100000000, 'DEBIT', FALSE, TRUE, FALSE),
  (34, 1, 3, 32, 'VND', 200000, 100000000, 'DEBIT', FALSE, TRUE, FALSE),
  (35, 1, 3, 33, 'VND', 200000, 100000000, 'DEBIT', FALSE, TRUE, FALSE),
  -- 3. ATM_ONLINE
  (36, 1, 4, 1, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  (37, 1, 4, 2, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  (38, 1, 4, 3, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  (39, 1, 4, 4, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  (40, 1, 4, 5, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  (41, 1, 4, 6, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  (42, 1, 4, 7, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  (43, 1, 4, 8, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  (44, 1, 4, 9, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  (45, 1, 4, 10, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  (46, 1, 4, 11, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  (47, 1, 4, 12, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  (48, 1, 4, 13, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  (49, 1, 4, 14, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  (50, 1, 4, 15, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  (51, 1, 4, 16, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  (52, 1, 4, 17, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  (53, 1, 4, 18, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  (54, 1, 4, 19, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  (55, 1, 4, 20, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  (56, 1, 4, 21, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  (57, 1, 4, 22, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  (58, 1, 4, 23, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  (59, 1, 4, 24, 'VND', 200000, 100000000, 'ATM', FALSE, TRUE, TRUE),
  -- 5. ATM_OFFLINE
  (60, 1, 5, 1, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (61, 1, 5, 2, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (62, 1, 5, 3, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (63, 1, 5, 4, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (64, 1, 5, 6, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (65, 1, 5, 8, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (66, 1, 5, 10, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (67, 1, 5, 14, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (68, 1, 5, 17, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (69, 1, 5, 18, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (70, 1, 5, 20, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (71, 1, 5, 22, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  -- 6. NH_OFFLINE
  (72, 1, 6, 1, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (73, 1, 6, 2, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (74, 1, 6, 3, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (75, 1, 6, 4, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (76, 1, 6, 5, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (77, 1, 6, 6, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (78, 1, 6, 8, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (79, 1, 6, 10, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (80, 1, 6, 14, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (81, 1, 6, 17, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (82, 1, 6, 18, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (83, 1, 6, 20, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (84, 1, 6, 22, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  -- 7. IB_ONLINE
  (85, 1, 7, 1, 'VND', 200000, 100000000, NULL, TRUE, TRUE, TRUE),
  (86, 1, 7, 2, 'VND', 200000, 100000000, NULL, TRUE, TRUE, TRUE),
  (87, 1, 7, 3, 'VND', 200000, 100000000, NULL, TRUE, TRUE, TRUE),
  (88, 1, 7, 6, 'VND', 200000, 100000000, NULL, TRUE, TRUE, TRUE),
  (89, 1, 7, 7, 'VND', 200000, 100000000, NULL, TRUE, TRUE, TRUE),
  (90, 1, 7, 18, 'VND', 200000, 100000000, NULL, TRUE, TRUE, TRUE),
  -- 8. QRCODE
  (91, 1, 8, 1, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (92, 1, 8, 5, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (93, 1, 8, 6, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (94, 1, 8, 7, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (95, 1, 8, 10, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (96, 1, 8, 11, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (97, 1, 8, 13, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (98, 1, 8, 17, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (99, 1, 8, 21, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (100, 1, 8, 22, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (101, 1, 8, 25, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (102, 1, 8, 26, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (103, 1, 8, 27, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (104, 1, 8, 28, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  (105, 1, 8, 29, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE),
  -- 9. CASH_IN_SHOP
  (106, 1, 9, 30, 'VND', 200000, 100000000, NULL, FALSE, TRUE, FALSE);

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

CREATE TYPE payment.PAYMENT_CARD_STATUS_ENUM AS ENUM ('ACTIVE', 'SUSPENDED', 'LOCKED');
CREATE SEQUENCE IF NOT EXISTS payment.payment_card_seq START 101;
DROP TABLE IF EXISTS payment.payment_card CASCADE;
CREATE TABLE IF NOT EXISTS payment.payment_card (
  id                 BIGINT           NOT NULL        DEFAULT nextval('payment.payment_card_seq' :: REGCLASS),
  username           VARCHAR(255)     NOT NULL,
  ccy                payment.CCY_ENUM NOT NULL,
  bank_id            INTEGER          NOT NULL,
  owner_name         VARCHAR(255)     NOT NULL,
  bank_account       VARCHAR(50),
  branch             VARCHAR(255),
  card_no            VARCHAR(50) UNIQUE,
  type               payment.PAYMENT_CARD_TYPE_ENUM,
  card_month         INTEGER          NOT NULL,
  card_year          INTEGER          NOT NULL,
  cvv                VARCHAR(255),
  status             payment.PAYMENT_CARD_STATUS_ENUM DEFAULT 'ACTIVE' :: payment.PAYMENT_CARD_STATUS_ENUM,

  version            BIGINT                           DEFAULT 0,
  created_date       TIMESTAMP                        DEFAULT CURRENT_TIMESTAMP,
  last_modified_date TIMESTAMP                        DEFAULT CURRENT_TIMESTAMP,
  created_by         VARCHAR(255),
  last_modified_by   VARCHAR(255),

  PRIMARY KEY (id),
  FOREIGN KEY (bank_id) REFERENCES payment.bank(id),
  UNIQUE (username, bank_id, type, ccy)
);

------------------------------------------------------------------------------------------------------------------------

CREATE TYPE payment.TX_STATUS_ENUM AS ENUM ('NEW', 'PENDING', 'IN_PROGRESS', 'SUCCESS', 'REJECTED', 'FAILED', 'CANCEL');

CREATE SEQUENCE IF NOT EXISTS payment.tx_seq START 101;
DROP TABLE IF EXISTS payment.tx CASCADE;
CREATE TABLE IF NOT EXISTS payment.tx (
  id                 BIGINT             NOT NULL DEFAULT nextval('payment.tx_seq' :: REGCLASS),
  code               VARCHAR(50) UNIQUE NOT NULL,
  username           VARCHAR(255)       NOT NULL,
  payment_channel_id INTEGER            NOT NULL,
  journal            VARCHAR(50)        NOT NULL,
  game_category      VARCHAR(50)        NOT NULL,
  exchange_rate      NUMERIC(30, 5),
  amt                NUMERIC(30, 2)     NOT NULL,
  fee                NUMERIC(30, 2),
  token              VARCHAR(255),
  checkout_url       TEXT,
  error_code         VARCHAR(50),
  invoice_no         VARCHAR(50),
  remark             TEXT,
  status             payment.TX_STATUS_ENUM      DEFAULT 'NEW' :: payment.TX_STATUS_ENUM,

  version            BIGINT                      DEFAULT 0,
  created_date       TIMESTAMP                   DEFAULT CURRENT_TIMESTAMP,
  last_modified_date TIMESTAMP                   DEFAULT CURRENT_TIMESTAMP,
  created_by         VARCHAR(255),
  last_modified_by   VARCHAR(255),

  PRIMARY KEY (id),
  FOREIGN KEY (payment_channel_id) REFERENCES payment.payment_channel(id),
  UNIQUE (token, payment_channel_id),
  CHECK (amt > 0)
);

------------------------------------------------------------------------------------------------------------------------