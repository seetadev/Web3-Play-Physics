SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA public;
COMMENT ON EXTENSION btree_gin IS 'support for indexing common datatypes in GIN';

CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE IF NOT EXISTS blocks_microblocks (
    uid BIGINT UNIQUE GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    id VARCHAR NOT NULL PRIMARY KEY,
    height INTEGER NOT NULL,
    time_stamp TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS asset_updates (
    block_uid BIGINT NOT NULL REFERENCES blocks_microblocks(uid),
    uid BIGINT UNIQUE GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    superseded_by BIGINT NOT NULL,
    asset_id VARCHAR NOT NULL,
    decimals SMALLINT NOT NULL,
    name VARCHAR NOT NULL,
    description VARCHAR NOT NULL,
    reissuable bool NOT NULL,
    volume BIGINT NOT NULL,
    script VARCHAR,
    sponsorship int8,
    nft bool NOT NULL,

    PRIMARY KEY (superseded_by, asset_id)
);

CREATE TABLE IF NOT EXISTS asset_origins (
    asset_id VARCHAR NOT NULL PRIMARY KEY,
    first_asset_update_uid BIGINT NOT NULL REFERENCES asset_updates(uid) ON DELETE CASCADE,
    origin_transaction_id VARCHAR NOT NULL,
    issuer VARCHAR NOT NULL,
    issue_height INTEGER NOT NULL,
    issue_time_stamp TIMESTAMPTZ NOT NULL
);

CREATE TABLE IF NOT EXISTS txs (
    uid BIGINT NOT NULL,
    tx_type SMALLINT NOT NULL,
    sender VARCHAR,
    sender_public_key VARCHAR,
    time_stamp TIMESTAMP WITH TIME ZONE NOT NULL,
    height INTEGER NOT NULL,
    id VARCHAR NOT NULL,
    signature VARCHAR,
    proofs TEXT[],
    tx_version SMALLINT,
    fee BIGINT NOT NULL,
    status VARCHAR DEFAULT 'succeeded' NOT NULL,
    block_uid BIGINT NOT NULL,

    CONSTRAINT txs_pk_uid_id_time_stamp PRIMARY KEY (uid, id, time_stamp),
    CONSTRAINT fk_blocks_uid FOREIGN KEY (block_uid) REFERENCES blocks_microblocks(uid)
);

CREATE TABLE IF NOT EXISTS txs_1 (
    recipient_address VARCHAR NOT NULL,
    recipient_alias VARCHAR,
    amount BIGINT NOT NULL,

    CONSTRAINT txs_1_pk_uid PRIMARY KEY (uid),
    CONSTRAINT fk_blocks_uid FOREIGN KEY (block_uid) REFERENCES blocks_microblocks(uid)
)
INHERITS (txs);

CREATE TABLE IF NOT EXISTS txs_2 (
    sender VARCHAR NOT NULL,
    sender_public_key VARCHAR NOT NULL,
    recipient_address VARCHAR NOT NULL,
    recipient_alias VARCHAR,
    amount BIGINT NOT NULL,

    CONSTRAINT txs_2_pk_uid PRIMARY KEY (uid),
    CONSTRAINT fk_blocks_uid FOREIGN KEY (block_uid) REFERENCES blocks_microblocks(uid)
)
INHERITS (txs);

CREATE TABLE IF NOT EXISTS txs_3 (
    sender VARCHAR NOT NULL,
    sender_public_key VARCHAR NOT NULL,
    asset_id VARCHAR NOT NULL,
    asset_name VARCHAR NOT NULL,
    description VARCHAR NOT NULL,
    quantity BIGINT NOT NULL,
    decimals SMALLINT NOT NULL,
    reissuable BOOLEAN NOT NULL,
    script VARCHAR,

    CONSTRAINT txs_3_pk_uid PRIMARY KEY (uid),
    CONSTRAINT fk_blocks_uid FOREIGN KEY (block_uid) REFERENCES blocks_microblocks(uid)
)
INHERITS (txs);

CREATE TABLE IF NOT EXISTS txs_4 (
    sender VARCHAR NOT NULL,
    sender_public_key VARCHAR NOT NULL,
    asset_id VARCHAR NOT NULL,
    amount BIGINT NOT NULL,
    recipient_address VARCHAR NOT NULL,
    recipient_alias VARCHAR,
    fee_asset_id VARCHAR NOT NULL,
    attachment VARCHAR NOT NULL,

    CONSTRAINT txs_4_pk_uid PRIMARY KEY (uid),
    CONSTRAINT fk_blocks_uid FOREIGN KEY (block_uid) REFERENCES blocks_microblocks(uid)
)
INHERITS (txs);
ALTER TABLE ONLY txs_4 ALTER COLUMN sender SET STATISTICS 1000;

CREATE TABLE IF NOT EXISTS txs_5 (
    sender VARCHAR NOT NULL,
    sender_public_key VARCHAR NOT NULL,
    asset_id VARCHAR NOT NULL,
    quantity BIGINT NOT NULL,
    reissuable BOOLEAN NOT NULL,

    CONSTRAINT txs_5_pk_uid PRIMARY KEY (uid),
    CONSTRAINT fk_blocks_uid FOREIGN KEY (block_uid) REFERENCES blocks_microblocks(uid)
)
INHERITS (txs);

CREATE TABLE IF NOT EXISTS txs_6 (
    sender VARCHAR NOT NULL,
    sender_public_key VARCHAR NOT NULL,
    asset_id VARCHAR NOT NULL,
    amount BIGINT NOT NULL,

    CONSTRAINT txs_6_pk_uid PRIMARY KEY (uid),
    CONSTRAINT fk_blocks_uid FOREIGN KEY (block_uid) REFERENCES blocks_microblocks(uid)
)
INHERITS (txs);

CREATE TABLE IF NOT EXISTS txs_7 (
    sender VARCHAR NOT NULL,
    sender_public_key VARCHAR NOT NULL,
    order1 jsonb NOT NULL,
    order2 jsonb NOT NULL,
    amount BIGINT NOT NULL,
    price BIGINT NOT NULL,
    amount_asset_id VARCHAR NOT NULL,
    price_asset_id VARCHAR NOT NULL,
    buy_matcher_fee BIGINT NOT NULL,
    sell_matcher_fee BIGINT NOT NULL,
    fee_asset_id VARCHAR NOT NULL,

    CONSTRAINT txs_7_pk_uid PRIMARY KEY (uid),
    CONSTRAINT fk_blocks_uid FOREIGN KEY (block_uid) REFERENCES blocks_microblocks(uid)
)
INHERITS (txs);

CREATE TABLE IF NOT EXISTS txs_8 (
    sender VARCHAR NOT NULL,
    sender_public_key VARCHAR NOT NULL,
    recipient_address VARCHAR NOT NULL,
    recipient_alias VARCHAR,
    amount BIGINT NOT NULL,

    CONSTRAINT txs_8_pk_uid PRIMARY KEY (uid),
    CONSTRAINT fk_blocks_uid FOREIGN KEY (block_uid) REFERENCES blocks_microblocks(uid)
)
INHERITS (txs);

CREATE TABLE IF NOT EXISTS txs_9 (
    sender VARCHAR NOT NULL,
    sender_public_key VARCHAR NOT NULL,
    lease_tx_uid BIGINT,

    CONSTRAINT txs_9_pk_uid PRIMARY KEY (uid),
    CONSTRAINT txs_9_un UNIQUE (uid, lease_tx_uid),
    CONSTRAINT fk_blocks_uid FOREIGN KEY (block_uid) REFERENCES blocks_microblocks(uid)
)
INHERITS (txs);

CREATE TABLE IF NOT EXISTS txs_10 (
    sender VARCHAR NOT NULL,
    sender_public_key VARCHAR NOT NULL,
    alias VARCHAR NOT NULL,

    CONSTRAINT txs_10_pk_uid PRIMARY KEY (uid),
    CONSTRAINT fk_blocks_uid FOREIGN KEY (block_uid) REFERENCES blocks_microblocks(uid)
)
INHERITS (txs);

CREATE TABLE IF NOT EXISTS txs_11 (
    sender VARCHAR NOT NULL,
    sender_public_key VARCHAR NOT NULL,
    asset_id VARCHAR NOT NULL,
    attachment VARCHAR NOT NULL,

    CONSTRAINT txs_11_pk_uid PRIMARY KEY (uid),
    CONSTRAINT fk_blocks_uid FOREIGN KEY (block_uid) REFERENCES blocks_microblocks(uid)
)
INHERITS (txs);

CREATE TABLE IF NOT EXISTS txs_11_transfers (
    tx_uid BIGINT NOT NULL,
    recipient_address VARCHAR NOT NULL,
    recipient_alias VARCHAR,
    amount bigint NOT NULL,
    position_in_tx smallint NOT NULL,
    height integer NOT NULL,

    PRIMARY KEY (tx_uid, position_in_tx),
    CONSTRAINT fk_tx_uid FOREIGN KEY (tx_uid) REFERENCES txs_11(uid) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS txs_12 (
    sender VARCHAR NOT NULL,
    sender_public_key VARCHAR NOT NULL,

    CONSTRAINT txs_12_pk_uid PRIMARY KEY (uid),
    CONSTRAINT fk_blocks_uid FOREIGN KEY (block_uid) REFERENCES blocks_microblocks(uid)
)
INHERITS (txs);

CREATE TABLE IF NOT EXISTS txs_12_data (
    tx_uid BIGINT NOT NULL,
    data_key TEXT NOT NULL,
    data_type TEXT,
    data_value_integer BIGINT,
    data_value_boolean BOOLEAN,
    data_value_binary TEXT,
    data_value_string TEXT,
    position_in_tx SMALLINT NOT NULL,
    height INTEGER NOT NULL,

    PRIMARY KEY (tx_uid, position_in_tx),
    CONSTRAINT fk_tx_uid FOREIGN KEY (tx_uid) REFERENCES txs_12(uid) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS txs_13 (
    sender VARCHAR NOT NULL,
    sender_public_key VARCHAR NOT NULL,
    script VARCHAR,

    CONSTRAINT txs_13_pk_uid PRIMARY KEY (uid),
    CONSTRAINT fk_blocks_uid FOREIGN KEY (block_uid) REFERENCES blocks_microblocks(uid)
)
INHERITS (txs);

CREATE TABLE IF NOT EXISTS txs_14 (
    sender VARCHAR NOT NULL,
    sender_public_key VARCHAR NOT NULL,
    asset_id VARCHAR NOT NULL,
    min_sponsored_asset_fee BIGINT,

    CONSTRAINT txs_14_pk_uid PRIMARY KEY (uid),
    CONSTRAINT fk_blocks_uid FOREIGN KEY (block_uid) REFERENCES blocks_microblocks(uid)
)
INHERITS (txs);

CREATE TABLE IF NOT EXISTS txs_15 (
    sender VARCHAR NOT NULL,
    sender_public_key VARCHAR NOT NULL,
    asset_id VARCHAR NOT NULL,
    script VARCHAR,

    CONSTRAINT txs_15_pk_uid PRIMARY KEY (uid),
    CONSTRAINT fk_blocks_uid FOREIGN KEY (block_uid) REFERENCES blocks_microblocks(uid)
)
INHERITS (txs);

CREATE TABLE IF NOT EXISTS txs_16 (
    sender VARCHAR NOT NULL,
    sender_public_key VARCHAR NOT NULL,
    dapp_address VARCHAR NOT NULL,
    dapp_alias VARCHAR,
    function_name VARCHAR,
    fee_asset_id VARCHAR NOT NULL,

    CONSTRAINT txs_16_pk_uid PRIMARY KEY (uid),
    CONSTRAINT fk_blocks_uid FOREIGN KEY (block_uid) REFERENCES blocks_microblocks(uid)
)
INHERITS (txs);

CREATE TABLE IF NOT EXISTS txs_16_args (
    arg_type TEXT NOT NULL,
    arg_value_integer BIGINT,
    arg_value_boolean BOOLEAN,
    arg_value_binary TEXT,
    arg_value_string TEXT,
    arg_value_list jsonb DEFAULT NULL,
    position_in_args SMALLINT NOT NULL,
    tx_uid BIGINT NOT NULL,
    height INTEGER,

    PRIMARY KEY (tx_uid, position_in_args),
    CONSTRAINT fk_tx_uid FOREIGN KEY (tx_uid) REFERENCES txs_16(uid) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS txs_16_payment (
    tx_uid BIGINT NOT NULL,
    amount BIGINT NOT NULL,
    position_in_payment SMALLINT NOT NULL,
    height INTEGER,
    asset_id VARCHAR NOT NULL,

    PRIMARY KEY (tx_uid, position_in_payment),
    CONSTRAINT fk_tx_uid FOREIGN KEY (tx_uid) REFERENCES txs_16(uid) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS txs_17
(
    sender VARCHAR NOT NULL,
    sender_public_key VARCHAR NOT NULL,
    asset_id VARCHAR NOT NULL,
    asset_name VARCHAR NOT NULL,
    description VARCHAR NOT NULL,

    CONSTRAINT txs_17_pk_uid PRIMARY KEY (uid),
    CONSTRAINT fk_blocks_uid FOREIGN KEY (block_uid) REFERENCES blocks_microblocks(uid)
)
INHERITS (txs);

CREATE TABLE IF NOT EXISTS txs_18
(
    payload BYTEA NOT NULL,
    function_name VARCHAR, -- null - transfer, not null - invoke

    CONSTRAINT txs_18_pk_uid PRIMARY KEY (uid),
    CONSTRAINT fk_blocks_uid FOREIGN KEY (block_uid) REFERENCES blocks_microblocks(uid)
)
INHERITS (txs);

CREATE TABLE IF NOT EXISTS txs_18_args (
    arg_type TEXT NOT NULL,
    arg_value_integer BIGINT,
    arg_value_boolean BOOLEAN,
    arg_value_binary TEXT,
    arg_value_string TEXT,
    arg_value_list jsonb DEFAULT NULL,
    position_in_args SMALLINT NOT NULL,
    tx_uid BIGINT NOT NULL,
    height INTEGER,

    PRIMARY KEY (tx_uid, position_in_args),
    CONSTRAINT fk_tx_uid FOREIGN KEY (tx_uid) REFERENCES txs_18(uid) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS txs_18_payment (
    tx_uid BIGINT NOT NULL,
    amount BIGINT NOT NULL,
    position_in_payment SMALLINT NOT NULL,
    height INTEGER,
    asset_id VARCHAR NOT NULL,

    PRIMARY KEY (tx_uid, position_in_payment),
    CONSTRAINT fk_tx_uid FOREIGN KEY (tx_uid) REFERENCES txs_18(uid) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS assets_metadata (
    asset_id VARCHAR,
    asset_name VARCHAR,
    ticker VARCHAR,
    height INTEGER,

    CONSTRAINT asset_meta_pk PRIMARY KEY (asset_id)
);

CREATE TABLE IF NOT EXISTS candles (
    time_start timestamp without time zone NOT NULL,
    amount_asset_id character varying(255) NOT NULL,
    price_asset_id character varying(255) NOT NULL,
    low numeric NOT NULL,
    high numeric NOT NULL,
    volume numeric NOT NULL,
    quote_volume numeric NOT NULL,
    max_height integer NOT NULL,
    txs_count integer NOT NULL,
    weighted_average_price numeric NOT NULL,
    open numeric NOT NULL,
    close numeric NOT NULL,
    interval varchar NOT NULL,
    matcher_address varchar NOT NULL,

    PRIMARY KEY (interval, time_start, amount_asset_id, price_asset_id, matcher_address)
);

CREATE TABLE IF NOT EXISTS pairs (
    amount_asset_id character varying(255) NOT NULL,
    price_asset_id character varying(255) NOT NULL,
    first_price numeric NOT NULL,
    last_price numeric NOT NULL,
    volume numeric NOT NULL,
    volume_waves numeric,
    quote_volume numeric NOT NULL,
    high numeric NOT NULL,
    low numeric NOT NULL,
    weighted_average_price numeric NOT NULL,
    txs_count integer NOT NULL,
    matcher_address character varying(255) NOT NULL,

    PRIMARY KEY (amount_asset_id, price_asset_id, matcher_address)
);

CREATE TABLE IF NOT EXISTS waves_data (
	height int4 NULL,
    -- quantity никогда не может быть одинаковым у двух записей
	quantity numeric NOT NULL PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS asset_tickers (
    uid BIGINT GENERATED BY DEFAULT AS IDENTITY,
    superseded_by BIGINT DEFAULT 9223372036854775806 NOT NULL,
    block_uid BIGINT NOT NULL CONSTRAINT data_entries_block_uid_fkey REFERENCES blocks_microblocks (uid) ON DELETE CASCADE,
    asset_id TEXT NOT NULL,
    ticker TEXT NOT NULL,

    PRIMARY KEY (superseded_by, asset_id)
);

CREATE OR REPLACE VIEW tickers(
    asset_id,
    ticker
) as SELECT asset_id, ticker FROM asset_tickers;

CREATE OR REPLACE VIEW assets(
    asset_id,
    ticker,
    asset_name,
    description,
    sender,
    issue_height,
    issue_timestamp,
    total_quantity,
    decimals,
    reissuable,
    has_script,
    min_sponsored_asset_fee
) AS
SELECT au.asset_id,
    t.ticker,
    au.name             AS asset_name,
    au.description,
    ao.issuer           AS sender,
    ao.issue_height,
    ao.issue_time_stamp AS issue_timestamp,
    au.volume           AS total_quantity,
    au.decimals,
    au.reissuable,
    CASE
        WHEN au.script IS NOT NULL THEN true
        ELSE false
        END             AS has_script,
    au.sponsorship      AS min_sponsored_asset_fee
FROM asset_updates au
    LEFT JOIN (SELECT tickers.asset_id, tickers.ticker FROM tickers) t ON au.asset_id::text = t.asset_id
    LEFT JOIN asset_origins ao ON au.asset_id::text = ao.asset_id::text
WHERE au.superseded_by = '9223372036854775806'::bigint
UNION ALL
SELECT 'WAVES'::character varying                         AS asset_id,
       'WAVES'::text                                      AS ticker,
       'Waves'::character varying                         AS asset_name,
       ''::character varying                              AS description,
       ''::character varying                              AS sender,
       0                                                  AS issue_height,
       '2016-04-11 21:00:00+00'::timestamp with time zone AS issue_timestamp,
       ((SELECT waves_data.quantity
         FROM waves_data
         ORDER BY waves_data.height DESC NULLS LAST
         LIMIT 1))::bigint::numeric                       AS total_quantity,
       8                                                  AS decimals,
       false                                              AS reissuable,
       false                                              AS has_script,
       NULL::bigint                                       AS min_sponsored_asset_fee;

CREATE OR REPLACE FUNCTION public.text_timestamp_cast(text) RETURNS timestamp without time zone
    LANGUAGE plpgsql
    AS $_$
begin
--   raise notice $1;
  return to_timestamp($1 :: DOUBLE PRECISION / 1000);
END
$_$;

CREATE UNIQUE INDEX IF NOT EXISTS txs_1_uid_time_stamp_unique_idx  ON txs_1  (uid, time_stamp);
CREATE UNIQUE INDEX IF NOT EXISTS txs_2_uid_time_stamp_unique_idx  ON txs_2  (uid, time_stamp);
CREATE UNIQUE INDEX IF NOT EXISTS txs_3_uid_time_stamp_unique_idx  ON txs_3  (uid, time_stamp);
CREATE UNIQUE INDEX IF NOT EXISTS txs_4_uid_time_stamp_unique_idx  ON txs_4  (uid, time_stamp);
CREATE UNIQUE INDEX IF NOT EXISTS txs_5_uid_time_stamp_unique_idx  ON txs_5  (uid, time_stamp);
CREATE UNIQUE INDEX IF NOT EXISTS txs_6_uid_time_stamp_unique_idx  ON txs_6  (uid, time_stamp);
CREATE UNIQUE INDEX IF NOT EXISTS txs_7_uid_time_stamp_unique_idx  ON txs_7  (uid, time_stamp);
CREATE UNIQUE INDEX IF NOT EXISTS txs_8_uid_time_stamp_unique_idx  ON txs_8  (uid, time_stamp);
CREATE UNIQUE INDEX IF NOT EXISTS txs_9_uid_time_stamp_unique_idx  ON txs_9  (uid, time_stamp);
CREATE UNIQUE INDEX IF NOT EXISTS txs_10_uid_time_stamp_unique_idx ON txs_10 (uid, time_stamp);
CREATE UNIQUE INDEX IF NOT EXISTS txs_11_uid_time_stamp_unique_idx ON txs_11 (uid, time_stamp);
CREATE UNIQUE INDEX IF NOT EXISTS txs_12_uid_time_stamp_unique_idx ON txs_12 (uid, time_stamp);
CREATE UNIQUE INDEX IF NOT EXISTS txs_13_uid_time_stamp_unique_idx ON txs_13 (uid, time_stamp);
CREATE UNIQUE INDEX IF NOT EXISTS txs_14_uid_time_stamp_unique_idx ON txs_14 (uid, time_stamp);
CREATE UNIQUE INDEX IF NOT EXISTS txs_15_uid_time_stamp_unique_idx ON txs_15 (uid, time_stamp);
CREATE UNIQUE INDEX IF NOT EXISTS txs_16_uid_time_stamp_unique_idx ON txs_16 (uid, time_stamp);
CREATE UNIQUE INDEX IF NOT EXISTS txs_17_uid_time_stamp_unique_idx ON txs_17 (uid, time_stamp);
CREATE UNIQUE INDEX IF NOT EXISTS txs_18_uid_time_stamp_unique_idx ON txs_18 (uid, time_stamp);

CREATE INDEX IF NOT EXISTS txs_height_idx               ON txs    USING btree (height);
CREATE INDEX IF NOT EXISTS txs_1_height_idx             ON txs_1  USING btree (height);
CREATE INDEX IF NOT EXISTS txs_2_height_idx             ON txs_2  USING btree (height);
CREATE INDEX IF NOT EXISTS txs_3_height_idx             ON txs_3  USING btree (height);
CREATE INDEX IF NOT EXISTS txs_5_height_idx             ON txs_5  USING btree (height);
CREATE INDEX IF NOT EXISTS txs_6_height_idx             ON txs_6  USING btree (height);
CREATE INDEX IF NOT EXISTS txs_7_height_idx             ON txs_7  USING btree (height);
CREATE INDEX IF NOT EXISTS txs_8_height_idx             ON txs_8  USING btree (height);
CREATE INDEX IF NOT EXISTS txs_9_height_idx             ON txs_9  USING btree (height);
CREATE INDEX IF NOT EXISTS txs_10_height_idx            ON txs_10 USING btree (height);
CREATE INDEX IF NOT EXISTS txs_11_height_idx            ON txs_11 USING btree (height);
CREATE INDEX IF NOT EXISTS txs_11_transfers_height_idx  ON txs_11_transfers USING btree (height);
CREATE INDEX IF NOT EXISTS txs_12_height_idx            ON txs_12 USING btree (height);
CREATE INDEX IF NOT EXISTS txs_12_data_height_idx       ON txs_12_data      USING btree (height);
CREATE INDEX IF NOT EXISTS txs_13_height_idx            ON txs_13 USING btree (height);
CREATE INDEX IF NOT EXISTS txs_14_height_idx            ON txs_14 USING btree (height);
CREATE INDEX IF NOT EXISTS txs_15_height_idx            ON txs_15 USING btree (height);
CREATE INDEX IF NOT EXISTS txs_16_height_idx            ON txs_16 USING btree (height);
CREATE INDEX IF NOT EXISTS txs_16_args_height_idx       ON txs_16_args      USING btree (height);
CREATE INDEX IF NOT EXISTS txs_16_payment_height_idx    ON txs_16_payment   USING btree (height);
CREATE INDEX IF NOT EXISTS txs_17_height_idx            ON txs_17 USING btree (height);
CREATE INDEX IF NOT EXISTS txs_18_height_idx            ON txs_18 USING btree (height);
CREATE INDEX IF NOT EXISTS txs_18_args_height_idx       ON txs_18_args      USING btree (height);
CREATE INDEX IF NOT EXISTS txs_18_payment_height_idx    ON txs_18_payment   USING btree (height);

CREATE INDEX IF NOT EXISTS txs_sender_uid_idx    ON txs    USING btree (sender, uid);
CREATE INDEX IF NOT EXISTS txs_1_sender_uid_idx  ON txs_1  USING btree (sender, uid);
CREATE INDEX IF NOT EXISTS txs_2_sender_uid_idx  ON txs_2  USING btree (sender, uid);
CREATE INDEX IF NOT EXISTS txs_3_sender_uid_idx  ON txs_3  USING btree (sender, uid);
CREATE INDEX IF NOT EXISTS txs_5_sender_uid_idx  ON txs_5  USING btree (sender, uid);
CREATE INDEX IF NOT EXISTS txs_6_sender_uid_idx  ON txs_6  USING btree (sender, uid);
CREATE INDEX IF NOT EXISTS txs_7_sender_uid_idx  ON txs_7  USING btree (sender, uid);
CREATE INDEX IF NOT EXISTS txs_8_sender_uid_idx  ON txs_8  USING btree (sender, uid);
CREATE INDEX IF NOT EXISTS txs_9_sender_uid_idx  ON txs_9  USING btree (sender, uid);
CREATE INDEX IF NOT EXISTS txs_10_sender_uid_idx ON txs_10 USING btree (sender, uid);
CREATE INDEX IF NOT EXISTS txs_11_sender_uid_idx ON txs_11 USING btree (sender, uid);
CREATE INDEX IF NOT EXISTS txs_12_sender_uid_idx ON txs_12 USING btree (sender, uid);
CREATE INDEX IF NOT EXISTS txs_13_sender_uid_idx ON txs_13 USING btree (sender, uid);
CREATE INDEX IF NOT EXISTS txs_14_sender_uid_idx ON txs_14 USING btree (sender, uid);
CREATE INDEX IF NOT EXISTS txs_15_sender_uid_idx ON txs_15 USING btree (sender, uid);
CREATE INDEX IF NOT EXISTS txs_16_sender_uid_idx ON txs_16 USING btree (sender, uid);
CREATE INDEX IF NOT EXISTS txs_17_sender_uid_idx ON txs_17 USING btree (sender, uid);
CREATE INDEX IF NOT EXISTS txs_18_sender_uid_idx ON txs_18 USING btree (sender, uid);

CREATE INDEX IF NOT EXISTS txs_id_idx    ON txs    USING hash (id);
CREATE INDEX IF NOT EXISTS txs_1_id_idx  ON txs_1  USING hash (id);
CREATE INDEX IF NOT EXISTS txs_2_id_idx  ON txs_2  USING hash (id);
CREATE INDEX IF NOT EXISTS txs_3_id_idx  ON txs_3  USING hash (id);
CREATE INDEX IF NOT EXISTS txs_4_id_idx  ON txs_4  USING hash (id);
CREATE INDEX IF NOT EXISTS txs_5_id_idx  ON txs_5  USING hash (id);
CREATE INDEX IF NOT EXISTS txs_6_id_idx  ON txs_6  USING hash (id);
CREATE INDEX IF NOT EXISTS txs_7_id_idx  ON txs_7  USING hash (id);
CREATE INDEX IF NOT EXISTS txs_8_id_idx  ON txs_8  USING hash (id);
CREATE INDEX IF NOT EXISTS txs_9_id_idx  ON txs_9  USING hash (id);
CREATE INDEX IF NOT EXISTS txs_10_id_idx ON txs_10 USING hash (id);
CREATE INDEX IF NOT EXISTS txs_11_id_idx ON txs_11 USING hash (id);
CREATE INDEX IF NOT EXISTS txs_12_id_idx ON txs_12 USING hash (id);
CREATE INDEX IF NOT EXISTS txs_13_id_idx ON txs_13 USING hash (id);
CREATE INDEX IF NOT EXISTS txs_14_id_idx ON txs_14 USING hash (id);
CREATE INDEX IF NOT EXISTS txs_15_id_idx ON txs_15 USING hash (id);
CREATE INDEX IF NOT EXISTS txs_16_id_idx ON txs_16 USING hash (id);
CREATE INDEX IF NOT EXISTS txs_17_id_idx ON txs_17 USING hash (id);
CREATE INDEX IF NOT EXISTS txs_18_id_idx ON txs_18 USING hash (id);

CREATE INDEX IF NOT EXISTS txs_time_stamp_uid_gist_idx    ON txs    USING gist (time_stamp, uid);
CREATE INDEX IF NOT EXISTS txs_1_time_stamp_uid_gist_idx  ON txs_1  USING gist (time_stamp, uid);
CREATE INDEX IF NOT EXISTS txs_2_time_stamp_uid_gist_idx  ON txs_2  USING gist (time_stamp, uid);
CREATE INDEX IF NOT EXISTS txs_3_time_stamp_uid_gist_idx  ON txs_3  USING gist (time_stamp, uid);
CREATE INDEX IF NOT EXISTS txs_4_time_stamp_uid_gist_idx  ON txs_4  USING gist (time_stamp, uid);
CREATE INDEX IF NOT EXISTS txs_5_time_stamp_uid_gist_idx  ON txs_5  USING gist (time_stamp, uid);
CREATE INDEX IF NOT EXISTS txs_6_time_stamp_uid_gist_idx  ON txs_6  USING gist (time_stamp, uid);
CREATE INDEX IF NOT EXISTS txs_7_time_stamp_uid_gist_idx  ON txs_7  USING gist (time_stamp, uid);
CREATE INDEX IF NOT EXISTS txs_8_time_stamp_uid_gist_idx  ON txs_8  USING gist (time_stamp, uid);
CREATE INDEX IF NOT EXISTS txs_9_time_stamp_uid_gist_idx  ON txs_9  USING gist (time_stamp, uid);
CREATE INDEX IF NOT EXISTS txs_10_time_stamp_uid_gist_idx ON txs_10 USING gist (time_stamp, uid);
CREATE INDEX IF NOT EXISTS txs_11_time_stamp_uid_gist_idx ON txs_11 USING gist (time_stamp, uid);
CREATE INDEX IF NOT EXISTS txs_12_time_stamp_uid_gist_idx ON txs_12 USING gist (time_stamp, uid);
CREATE INDEX IF NOT EXISTS txs_13_time_stamp_uid_gist_idx ON txs_13 USING gist (time_stamp, uid);
CREATE INDEX IF NOT EXISTS txs_14_time_stamp_uid_gist_idx ON txs_14 USING gist (time_stamp, uid);
CREATE INDEX IF NOT EXISTS txs_15_time_stamp_uid_gist_idx ON txs_15 USING gist (time_stamp, uid);
CREATE INDEX IF NOT EXISTS txs_16_time_stamp_uid_gist_idx ON txs_16 USING gist (time_stamp, uid);
CREATE INDEX IF NOT EXISTS txs_17_time_stamp_uid_gist_idx ON txs_17 USING gist (time_stamp, uid);
CREATE INDEX IF NOT EXISTS txs_18_time_stamp_uid_gist_idx ON txs_18 USING gist (time_stamp, uid);

CREATE INDEX IF NOT EXISTS txs_1_block_uid_idx  ON txs_1  (block_uid);
CREATE INDEX IF NOT EXISTS txs_2_block_uid_idx  ON txs_2  (block_uid);
CREATE INDEX IF NOT EXISTS txs_3_block_uid_idx  ON txs_3  (block_uid);
CREATE INDEX IF NOT EXISTS txs_4_block_uid_idx  ON txs_4  (block_uid);
CREATE INDEX IF NOT EXISTS txs_5_block_uid_idx  ON txs_5  (block_uid);
CREATE INDEX IF NOT EXISTS txs_6_block_uid_idx  ON txs_6  (block_uid);
CREATE INDEX IF NOT EXISTS txs_7_block_uid_idx  ON txs_7  (block_uid);
CREATE INDEX IF NOT EXISTS txs_8_block_uid_idx  ON txs_8  (block_uid);
CREATE INDEX IF NOT EXISTS txs_9_block_uid_idx  ON txs_9  (block_uid);
CREATE INDEX IF NOT EXISTS txs_10_block_uid_idx ON txs_10 (block_uid);
CREATE INDEX IF NOT EXISTS txs_11_block_uid_idx ON txs_11 (block_uid);
CREATE INDEX IF NOT EXISTS txs_12_block_uid_idx ON txs_12 (block_uid);
CREATE INDEX IF NOT EXISTS txs_13_block_uid_idx ON txs_13 (block_uid);
CREATE INDEX IF NOT EXISTS txs_14_block_uid_idx ON txs_14 (block_uid);
CREATE INDEX IF NOT EXISTS txs_15_block_uid_idx ON txs_15 (block_uid);
CREATE INDEX IF NOT EXISTS txs_16_block_uid_idx ON txs_16 (block_uid);
CREATE INDEX IF NOT EXISTS txs_17_block_uid_idx ON txs_17 (block_uid);
CREATE INDEX IF NOT EXISTS txs_18_block_uid_idx ON txs_18 (block_uid);

CREATE INDEX IF NOT EXISTS txs_3_asset_id_uid_idx  ON txs_3  USING btree (asset_id, uid);
CREATE INDEX IF NOT EXISTS txs_4_asset_id_uid_idx  ON txs_4  USING btree (asset_id, uid);
CREATE INDEX IF NOT EXISTS txs_5_asset_id_uid_idx  ON txs_5  USING btree (asset_id, uid);
CREATE INDEX IF NOT EXISTS txs_6_asset_id_uid_idx  ON txs_6  USING btree (asset_id, uid);
CREATE INDEX IF NOT EXISTS txs_11_asset_id_uid_idx ON txs_11 USING btree (asset_id, uid);

CREATE INDEX IF NOT EXISTS txs_3_md5_script_idx  ON txs_3  USING btree (md5((script)::text));
CREATE INDEX IF NOT EXISTS txs_13_md5_script_idx ON txs_13 USING btree (md5((script)::text));
CREATE INDEX IF NOT EXISTS txs_15_md5_script_idx ON txs_15 USING btree (md5((script)::text));

CREATE INDEX IF NOT EXISTS txs_8_recipient_idx ON txs_8 USING btree (recipient_address);
CREATE INDEX IF NOT EXISTS txs_11_transfers_recipient_address_idx ON txs_11_transfers USING btree (recipient_address);

CREATE INDEX IF NOT EXISTS txs_tx_type_idx                   ON txs USING btree (tx_type);
CREATE INDEX IF NOT EXISTS txs_time_stamp_uid_idx            ON txs USING btree (time_stamp, uid);
CREATE INDEX IF NOT EXISTS txs_4_height_uid_idx              ON txs_4 USING btree (height, uid);
CREATE INDEX IF NOT EXISTS txs_4_recipient_address_uid_idx   ON txs_4 (recipient_address, uid);
CREATE INDEX IF NOT EXISTS txs_4_sender_uid_idx              ON txs_4 (sender, uid);
CREATE INDEX IF NOT EXISTS txs_7_order_ids_uid_idx           ON txs_7 USING gin ((ARRAY[order1->>'id', order2->>'id']), uid);
CREATE INDEX IF NOT EXISTS txs_7_order_senders_uid_idx       ON txs_7 USING gin ((ARRAY[order1->>'sender', order2->>'sender']), uid);
CREATE INDEX IF NOT EXISTS txs_7_price_asset_id_uid_idx      ON txs_7 (price_asset_id, uid);
CREATE INDEX IF NOT EXISTS txs_7_time_stamp_gist_idx         ON txs_7 USING gist (time_stamp);
CREATE INDEX IF NOT EXISTS txs_7_amount_asset_id_uid_idx     ON txs_7 (amount_asset_id, uid);
CREATE INDEX IF NOT EXISTS txs_7_order_sender_1_uid_desc_idx ON txs_7 ((order1 ->> 'sender'::text) asc, uid desc);
CREATE INDEX IF NOT EXISTS txs_7_order_sender_2_uid_desc_idx ON txs_7 ((order2 ->> 'sender'::text) asc, uid desc);
CREATE INDEX IF NOT EXISTS txs_7_uid_height_time_stamp_idx   ON txs_7 (uid, height, time_stamp);
CREATE INDEX IF NOT EXISTS txs_7_amount_asset_id_price_asset_id_uid_idx ON txs_7 (amount_asset_id, price_asset_id, uid);
CREATE INDEX IF NOT EXISTS txs_8_recipient_address_uid_idx   ON txs_8 USING btree (recipient_address, uid);
CREATE INDEX IF NOT EXISTS txs_10_alias_sender_idx           ON txs_10 USING btree (alias, sender);
CREATE INDEX IF NOT EXISTS txs_10_alias_uid_idx              ON txs_10 USING btree (alias, uid);
CREATE INDEX IF NOT EXISTS txs_12_data_data_value_binary_tx_uid_partial_idx
    ON txs_12_data USING hash (data_value_binary) WHERE (data_type = 'binary'::text);
CREATE INDEX IF NOT EXISTS txs_12_data_data_value_boolean_tx_uid_partial_idx
    ON txs_12_data USING btree (data_value_boolean, tx_uid) WHERE (data_type = 'boolean'::text);
CREATE INDEX IF NOT EXISTS txs_12_data_data_value_integer_tx_uid_partial_idx
    ON txs_12_data USING btree (data_value_integer, tx_uid) WHERE (data_type = 'integer'::text);
CREATE INDEX IF NOT EXISTS txs_12_data_data_value_string_tx_uid_partial_idx
    ON txs_12_data USING hash (data_value_string) WHERE (data_type = 'string'::text);
CREATE INDEX IF NOT EXISTS txs_12_data_tx_uid_idx            ON txs_12_data USING btree (tx_uid);
CREATE INDEX IF NOT EXISTS txs_12_data_data_key_tx_uid_idx   ON txs_12_data USING btree (data_key, tx_uid);
CREATE INDEX IF NOT EXISTS txs_12_data_data_type_tx_uid_idx  ON txs_12_data USING btree (data_type, tx_uid);
CREATE INDEX IF NOT EXISTS txs_16_dapp_address_uid_idx       ON txs_16 USING btree (dapp_address, uid);
CREATE INDEX IF NOT EXISTS txs_16_function_name_uid_idx      ON txs_16 (function_name, uid);
CREATE INDEX IF NOT EXISTS txs_16_payment_asset_id_idx       ON txs_16_payment USING btree (asset_id);
CREATE INDEX IF NOT EXISTS txs_16_sender_time_stamp_uid_idx  ON txs_16 (sender, time_stamp, uid);
CREATE INDEX IF NOT EXISTS txs_16_dapp_address_function_name_uid_idx ON txs_16 (dapp_address, function_name, uid);
CREATE INDEX IF NOT EXISTS txs_17_sender_time_stamp_id_idx   ON txs_17 (sender, time_stamp, uid);
CREATE INDEX IF NOT EXISTS txs_17_asset_id_uid_idx           ON txs_17 (asset_id, uid);
CREATE INDEX IF NOT EXISTS txs_18_function_name_uid_idx      ON txs_18 (function_name, uid);
CREATE INDEX IF NOT EXISTS txs_18_payment_asset_id_idx       ON txs_18_payment USING btree (asset_id);

CREATE INDEX IF NOT EXISTS asset_updates_to_tsvector_idx
    ON asset_updates USING gin (to_tsvector('simple'::regconfig, name::TEXT))
    WHERE (superseded_by = '9223372036854775806'::BIGINT);
CREATE INDEX IF NOT EXISTS asset_updates_block_uid_idx  ON asset_updates (block_uid);
CREATE INDEX IF NOT EXISTS blocks_microblocks_time_stamp_uid_idx ON blocks_microblocks (time_stamp DESC, uid DESC);
CREATE INDEX IF NOT EXISTS blocks_microblocks_id_idx    ON blocks_microblocks (id);
CREATE INDEX IF NOT EXISTS candles_max_height_index     ON candles USING btree (max_height);
CREATE INDEX IF NOT EXISTS candles_amount_price_ids_matcher_time_start_partial_1m_idx
    ON candles (amount_asset_id, price_asset_id, matcher_address, time_start) WHERE (("interval")::text = '1m'::text);
CREATE INDEX IF NOT EXISTS candles_assets_id_idx
    ON public.candles USING btree (amount_asset_id, price_asset_id)
    WHERE ((("interval")::text = '1d'::text) AND ((matcher_address)::text = '3PEjHv3JGjcWNpYEEkif2w8NXV4kbhnoGgu'::text));
CREATE INDEX IF NOT EXISTS waves_data_height_desc_quantity_idx ON waves_data (height DESC NULLS LAST, quantity);
CREATE UNIQUE INDEX IF NOT EXISTS asset_tickers_ticker_idx    ON asset_tickers (ticker);
