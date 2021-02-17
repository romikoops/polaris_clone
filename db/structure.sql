SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: tablefunc; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA public;


--
-- Name: EXTENSION tablefunc; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION tablefunc IS 'functions that manipulate whole tables, including crosstab';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: journey_colli_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.journey_colli_type AS ENUM (
    'barrel',
    'bottle',
    'carton',
    'case',
    'crate',
    'drum',
    'package',
    'pallet',
    'roll',
    'skid',
    'stack'
);


--
-- Name: journey_document_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.journey_document_type AS ENUM (
    'commercial_invoice',
    'dock_receipt',
    'bill_of_lading',
    'certificate_of_origin',
    'warehouse_receipt',
    'inspection_certificate',
    'export_license',
    'packing_list',
    'health_certificate',
    'insurance_certificate',
    'consular_documents',
    'free_trade_document',
    'shippers_letter_of_instruction',
    'destination_control_statement'
);


--
-- Name: journey_load_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.journey_load_type AS ENUM (
    'lcl',
    'fcl'
);


--
-- Name: journey_mode_of_transport; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.journey_mode_of_transport AS ENUM (
    'ocean',
    'air',
    'rail',
    'truck',
    'carriage'
);


--
-- Name: journey_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.journey_status AS ENUM (
    'queued',
    'running',
    'completed',
    'failed'
);


--
-- Name: get_latin_name(text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_latin_name(name text, local_name text, int_name text, name_en text) RETURNS text
    LANGUAGE plpgsql
    AS $$
 BEGIN
  IF (name is not NULL) and (name !='') and (is_latin(name)) THEN
   return name;
  ELSE
   IF (local_name is NULL) THEN
    IF (int_name is NULL) THEN
     IF (name_en is NULL) THEN
      IF (name is not NULL) and (name !='') THEN
       return transliterate(name); 
      ELSE
       return NULL;
      END IF;
     ELSE
      return name_en;
     END IF;
    ELSE
     return int_name;
    END IF;
   ELSE
    return local_name;
   END IF;
  END IF;
 END;
$$;


--
-- Name: get_localized_name_without_brackets(text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_localized_name_without_brackets(name text, local_name text, int_name text, name_en text) RETURNS text
    LANGUAGE plpgsql
    AS $$
  BEGIN
    IF (local_name is NULL) THEN
      IF (int_name is NULL) THEN
	IF (name_en is NULL) THEN
          if (name is NULL) THEN
            return NULL;
          END IF;
          if (name = '') THEN
            return '';
          END IF;
	  /* if transliteration is available add here with a latin1 check */
          IF is_latin(name) THEN
            return name;
          ELSE
            return transliterate(name);
          END IF;
	  return name;
	ELSE
	  IF (name_en != name) THEN
	    IF is_latin(name) THEN
	      return name;
	    ELSE
	      return name_en;
	    END IF;
          ELSE
            return name;
          END IF; 
	END IF;        
      ELSE
	IF (int_name != name) THEN
	  IF is_latin(name) THEN
	    return name;
	  ELSE
	   return int_name;
          END IF;
	ELSE
	  return name;
	END IF;
      END IF;
    ELSE
      return local_name;
    END IF;
  END;
$$;


--
-- Name: get_localized_placename(text, text, text, text, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_localized_placename(name text, local_name text, int_name text, name_en text, loc_in_brackets boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$
  BEGIN
    IF (local_name is NULL) THEN
      IF (int_name is NULL) THEN
	IF (name_en is NULL) THEN
          if (name is NULL) THEN
            return NULL;
          END IF;
          if (name = '') THEN
            return '';
          END IF;
	  /* if transliteration is available add here with a latin1 check */
          IF is_latin(name) THEN
            return name;
          ELSE
            return transliterate(name); 
          END IF;
	  return name;
	ELSE
	  IF (name_en != name) THEN
	    IF is_latin(name) THEN
	      return name;
	    ELSE
	      return name_en;
	    END IF;
          ELSE
            return name;
          END IF; 
	END IF;        
      ELSE
	IF (int_name != name) THEN
	  IF is_latin(name) THEN
	    return name;
	  ELSE
	   return int_name;
          END IF;
	ELSE
	  return name;
	END IF;
      END IF;
    ELSE
      IF (name is NULL) THEN
       return local_name;
      ELSE
        IF ( position(local_name in name)>0 or position('(' in name)>0 or position('(' in local_name)>0 ) THEN    
         IF ( loc_in_brackets ) THEN
          return name;                                                       
         ELSE
          return local_name;
         END IF;
        ELSE
         IF ( loc_in_brackets ) THEN
          IF ( is_latinorgreek(name)=false ) THEN
           return local_name;
          ELSE
           return name||' ('||local_name||')';
          END IF;
         ELSE
          IF ( is_latinorgreek(name)=false ) THEN
           return local_name;
          ELSE
           return local_name||' ('||name||')';
          END IF;
         END IF;
        END IF;
      END IF;
    END IF;
  END;
$$;


--
-- Name: get_localized_streetname(text, text, text, text, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_localized_streetname(name text, local_name text, int_name text, name_en text, loc_in_brackets boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$
  BEGIN
    IF (local_name is NULL) THEN
      IF (int_name is NULL) THEN
	IF (name_en is NULL) THEN
          if (name is NULL) THEN
            return NULL;
          END IF;
          if (name = '') THEN
            return '';
          END IF;
	  /* if transliteration is available add here with a latin1 check */
          IF is_latin(name) THEN
            return street_abbreviation(name);
          ELSE
            return transliterate(name); 
          END IF;
	  return name;
	ELSE
	  IF (name_en != name) THEN
	    IF is_latin(name) THEN
	      return street_abbreviation(name);
	    ELSE
	      return name_en;
	    END IF;
          ELSE
            return name;
          END IF; 
	END IF;        
      ELSE
	IF (int_name != name) THEN
	  IF is_latin(name) THEN
	    return street_abbreviation(name);
	  ELSE
	   return int_name;
          END IF;
	ELSE
	  return street_abbreviation(name);
	END IF;
      END IF;
    ELSE
      IF (name is NULL) THEN
       return street_abbreviation(local_name);
      ELSE
        IF ( position(local_name in name)>0 or position('(' in name)>0 or position('(' in local_name)>0 ) THEN    
         IF ( loc_in_brackets ) THEN
          return street_abbreviation(name);
         ELSE
          return street_abbreviation(local_name);
         END IF;
        ELSE
         IF ( loc_in_brackets ) THEN
          IF ( is_latinorgreek(name)=false ) THEN
           return street_abbreviation(local_name);
          ELSE
           return street_abbreviation(name||' ('||local_name||')');
          END IF;
         ELSE
          IF ( is_latinorgreek(name)=false ) THEN
           return street_abbreviation(local_name);
          ELSE
           return street_abbreviation(local_name||' ('||name||')');
          END IF;
         END IF;
        END IF;
      END IF;
    END IF;
  END;
$$;


--
-- Name: is_latin(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_latin(text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
  DECLARE
    i integer;
  BEGIN
    FOR i IN 1..char_length($1) LOOP
      IF (ascii(substr($1, i, 1)) > 591) THEN
        RETURN false;
      END IF;
    END LOOP;
    RETURN true;
  END;
$_$;


--
-- Name: is_latinorgreek(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_latinorgreek(text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
  DECLARE
    i integer;
  BEGIN
    FOR i IN 1..char_length($1) LOOP
      IF (ascii(substr($1, i, 1)) > 1327) THEN
        RETURN false;
      END IF;
    END LOOP;
    RETURN true;
  END;
$_$;


--
-- Name: street_abbreviation(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.street_abbreviation(text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
 DECLARE
  abbrev text;
 BEGIN
  abbrev=$1;
  IF (length(abbrev)<16) THEN
   return abbrev;
  END IF;
  IF (position('traße' in abbrev)>0) THEN
   abbrev=regexp_replace(abbrev,'Straße\M','Str.');
   abbrev=regexp_replace(abbrev,'straße\M','str.');
  END IF;
  IF (position('asse' in abbrev)>0) THEN
   abbrev=regexp_replace(abbrev,'Strasse\M','Str.');
   abbrev=regexp_replace(abbrev,'strasse\M','str.');
   abbrev=regexp_replace(abbrev,'Gasse\M','G.');
   abbrev=regexp_replace(abbrev,'gasse\M','g.');
  END IF;
  IF (position('latz' in abbrev)>0) THEN
   abbrev=regexp_replace(abbrev,'Platz\M','Pl.');
   abbrev=regexp_replace(abbrev,'platz\M','pl.');
  END IF;
  IF (position('Professor' in abbrev)>0) THEN
   abbrev=replace(abbrev,'Professor ','Prof. ');
   abbrev=replace(abbrev,'Professor-','Prof.-');
  END IF;
  IF (position('Doktor' in abbrev)>0) THEN
   abbrev=replace(abbrev,'Doktor ','Dr. ');
   abbrev=replace(abbrev,'Doktor-','Dr.-');
  END IF;
  IF (position('Bürgermeister' in abbrev)>0) THEN
   abbrev=replace(abbrev,'Bürgermeister ','Bgm. ');
   abbrev=replace(abbrev,'Bürgermeister-','Bgm.-');
  END IF;
  IF (position('Sankt' in abbrev)>0) THEN
   abbrev=replace(abbrev,'Sankt ','St. ');
   abbrev=replace(abbrev,'Sankt-','St.-');
  END IF;
  return abbrev;
 END;
$_$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    record_id uuid NOT NULL,
    record_type character varying NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: addons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.addons (
    id bigint NOT NULL,
    title character varying,
    text jsonb[] DEFAULT '{}'::jsonb[],
    tenant_id integer,
    read_more character varying,
    accept_text character varying,
    decline_text character varying,
    additional_info_text character varying,
    cargo_class character varying,
    hub_id integer,
    counterpart_hub_id integer,
    mode_of_transport character varying,
    tenant_vehicle_id integer,
    direction character varying,
    addon_type character varying,
    fees jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization_id uuid
);


--
-- Name: addons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.addons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: addons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.addons_id_seq OWNED BY public.addons.id;


--
-- Name: address_book_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.address_book_contacts (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legacy_user_id uuid,
    sandbox_id uuid,
    company_name character varying,
    first_name character varying,
    last_name character varying,
    phone character varying,
    email character varying,
    point public.geometry,
    geocoded_address character varying,
    street character varying,
    street_number character varying,
    postal_code character varying,
    city character varying,
    province character varying,
    premise character varying,
    country_code character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tms_id character varying,
    user_id uuid
);


--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.addresses (
    id bigint NOT NULL,
    name character varying,
    location_type character varying,
    latitude double precision,
    longitude double precision,
    geocoded_address character varying,
    street character varying,
    street_number character varying,
    zip_code character varying,
    city character varying,
    street_address character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    province character varying,
    photo character varying,
    premise character varying,
    country_id integer,
    sandbox_id uuid,
    address_line_1 character varying,
    address_line_2 character varying,
    address_line_3 character varying,
    point public.geometry
);


--
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.addresses_id_seq OWNED BY public.addresses.id;


--
-- Name: agencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agencies (
    id bigint NOT NULL,
    name character varying,
    tenant_id integer,
    agency_manager_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization_id uuid
);


--
-- Name: agencies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.agencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agencies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.agencies_id_seq OWNED BY public.agencies.id;


--
-- Name: aggregated_cargos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.aggregated_cargos (
    id bigint NOT NULL,
    weight numeric,
    volume numeric,
    chargeable_weight numeric,
    shipment_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sandbox_id uuid,
    deleted_at timestamp without time zone
);


--
-- Name: aggregated_cargos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.aggregated_cargos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: aggregated_cargos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.aggregated_cargos_id_seq OWNED BY public.aggregated_cargos.id;


--
-- Name: alternative_names; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alternative_names (
    id bigint NOT NULL,
    model character varying,
    model_id character varying,
    name character varying,
    locale character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: alternative_names_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alternative_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alternative_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alternative_names_id_seq OWNED BY public.alternative_names.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cargo_cargos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cargo_cargos (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    tenant_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    quotation_id uuid,
    total_goods_value_cents integer DEFAULT 0 NOT NULL,
    total_goods_value_currency character varying NOT NULL,
    organization_id uuid
);


--
-- Name: cargo_item_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cargo_item_types (
    id bigint NOT NULL,
    dimension_x numeric,
    dimension_y numeric,
    description character varying,
    area character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    category character varying,
    width numeric,
    length numeric
);


--
-- Name: cargo_item_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cargo_item_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cargo_item_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cargo_item_types_id_seq OWNED BY public.cargo_item_types.id;


--
-- Name: cargo_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cargo_items (
    id bigint NOT NULL,
    shipment_id integer,
    payload_in_kg numeric,
    dimension_x numeric,
    dimension_y numeric,
    dimension_z numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    dangerous_goods boolean,
    cargo_class character varying,
    hs_codes character varying[] DEFAULT '{}'::character varying[],
    cargo_item_type_id integer,
    customs_text character varying,
    chargeable_weight numeric,
    stackable boolean DEFAULT true,
    quantity integer,
    unit_price jsonb,
    sandbox_id uuid,
    contents character varying,
    width numeric,
    length numeric,
    height numeric,
    deleted_at timestamp without time zone
);


--
-- Name: cargo_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cargo_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cargo_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cargo_items_id_seq OWNED BY public.cargo_items.id;


--
-- Name: cargo_units; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cargo_units (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    tenant_id uuid,
    quantity integer DEFAULT 0,
    cargo_class bigint DEFAULT 0,
    cargo_type bigint DEFAULT 0,
    stackable boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    weight_value numeric(100,3) DEFAULT 0.0,
    width_value numeric(100,4) DEFAULT 0.0,
    length_value numeric(100,4) DEFAULT 0.0,
    height_value numeric(100,4) DEFAULT 0.0,
    volume_value numeric(100,6) DEFAULT 0.0,
    volume_unit character varying DEFAULT 'm3'::character varying,
    weight_unit character varying DEFAULT 'kg'::character varying,
    width_unit character varying DEFAULT 'm'::character varying,
    length_unit character varying DEFAULT 'm'::character varying,
    height_unit character varying DEFAULT 'm'::character varying,
    cargo_id uuid,
    dangerous_goods integer DEFAULT 0,
    goods_value_cents integer DEFAULT 0 NOT NULL,
    goods_value_currency character varying NOT NULL,
    organization_id uuid,
    legacy_type character varying,
    legacy_id integer
);


--
-- Name: carriers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.carriers (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sandbox_id uuid,
    code character varying,
    deleted_at timestamp without time zone
);


--
-- Name: carriers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.carriers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: carriers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.carriers_id_seq OWNED BY public.carriers.id;


--
-- Name: charge_breakdowns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.charge_breakdowns (
    id bigint NOT NULL,
    shipment_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    trip_id integer,
    sandbox_id uuid,
    valid_until timestamp without time zone,
    tender_id uuid,
    freight_tenant_vehicle_id integer,
    pickup_tenant_vehicle_id integer,
    delivery_tenant_vehicle_id integer,
    deleted_at timestamp without time zone
);


--
-- Name: charge_breakdowns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.charge_breakdowns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: charge_breakdowns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.charge_breakdowns_id_seq OWNED BY public.charge_breakdowns.id;


--
-- Name: charge_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.charge_categories (
    id bigint NOT NULL,
    name character varying,
    code character varying,
    cargo_unit_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tenant_id integer,
    sandbox_id uuid,
    organization_id uuid
);


--
-- Name: charge_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.charge_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: charge_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.charge_categories_id_seq OWNED BY public.charge_categories.id;


--
-- Name: charges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.charges (
    id bigint NOT NULL,
    parent_id integer,
    price_id integer,
    charge_category_id integer,
    children_charge_category_id integer,
    charge_breakdown_id integer,
    detail_level integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    edited_price_id integer,
    sandbox_id uuid,
    line_item_id uuid,
    deleted_at timestamp without time zone
);


--
-- Name: charges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.charges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.charges_id_seq OWNED BY public.charges.id;


--
-- Name: cms_data_widgets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cms_data_widgets (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    "order" integer NOT NULL,
    data character varying NOT NULL,
    organization_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: companies_companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companies_companies (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    email character varying,
    phone character varying,
    name character varying,
    vat_number character varying,
    address_id integer,
    organization_id uuid,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tenants_company_id uuid,
    external_id character varying
);


--
-- Name: companies_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companies_memberships (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    member_type character varying,
    member_id uuid,
    company_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contacts (
    id bigint NOT NULL,
    legacy_user_id integer,
    address_id integer,
    company_name character varying,
    first_name character varying,
    last_name character varying,
    phone character varying,
    email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    alias boolean DEFAULT false,
    sandbox_id uuid,
    user_id uuid
);


--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- Name: containers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.containers (
    id bigint NOT NULL,
    shipment_id integer,
    size_class character varying,
    weight_class character varying,
    payload_in_kg numeric,
    tare_weight numeric,
    gross_weight numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    dangerous_goods boolean,
    cargo_class character varying,
    hs_codes character varying[] DEFAULT '{}'::character varying[],
    customs_text character varying,
    quantity integer,
    unit_price jsonb,
    sandbox_id uuid,
    contents character varying,
    deleted_at timestamp without time zone
);


--
-- Name: containers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.containers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: containers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.containers_id_seq OWNED BY public.containers.id;


--
-- Name: countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.countries (
    id bigint NOT NULL,
    name character varying,
    code character varying,
    flag character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.countries_id_seq OWNED BY public.countries.id;


--
-- Name: currencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.currencies (
    id bigint NOT NULL,
    today jsonb,
    yesterday jsonb,
    base character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tenant_id integer,
    organization_id uuid
);


--
-- Name: currencies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.currencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: currencies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.currencies_id_seq OWNED BY public.currencies.id;


--
-- Name: customs_fees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customs_fees (
    id bigint NOT NULL,
    mode_of_transport character varying,
    load_type character varying,
    hub_id integer,
    tenant_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tenant_vehicle_id integer,
    counterpart_hub_id integer,
    direction character varying,
    fees jsonb,
    organization_id uuid
);


--
-- Name: customs_fees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customs_fees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customs_fees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customs_fees_id_seq OWNED BY public.customs_fees.id;


--
-- Name: data_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.data_migrations (
    version character varying NOT NULL
);


--
-- Name: event_store_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_store_events (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    event_type character varying NOT NULL,
    metadata bytea,
    data bytea NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: event_store_events_in_streams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_store_events_in_streams (
    id bigint NOT NULL,
    stream character varying NOT NULL,
    "position" integer,
    event_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: event_store_events_in_streams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.event_store_events_in_streams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_store_events_in_streams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.event_store_events_in_streams_id_seq OWNED BY public.event_store_events_in_streams.id;


--
-- Name: exchange_rates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exchange_rates (
    id bigint NOT NULL,
    "from" character varying,
    "to" character varying,
    rate numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: exchange_rates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.exchange_rates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exchange_rates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.exchange_rates_id_seq OWNED BY public.exchange_rates.id;


--
-- Name: groups_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups_groups (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying,
    organization_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tenants_group_id uuid,
    deleted_at timestamp without time zone
);


--
-- Name: groups_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups_memberships (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    member_type character varying,
    member_id uuid,
    group_id uuid,
    priority integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: hubs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hubs (
    id bigint NOT NULL,
    tenant_id integer,
    address_id integer,
    name character varying,
    hub_type character varying,
    latitude double precision,
    longitude double precision,
    hub_status character varying DEFAULT 'active'::character varying,
    hub_code character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    trucking_type character varying,
    photo character varying,
    nexus_id integer,
    mandatory_charge_id integer,
    sandbox_id uuid,
    free_out boolean DEFAULT false,
    point public.geometry(Geometry,4326),
    organization_id uuid
);


--
-- Name: hubs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hubs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hubs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hubs_id_seq OWNED BY public.hubs.id;


--
-- Name: incoterm_charges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.incoterm_charges (
    id bigint NOT NULL,
    pre_carriage boolean,
    on_carriage boolean,
    freight boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    origin_warehousing boolean,
    origin_labour boolean,
    origin_packing boolean,
    origin_loading boolean,
    origin_customs boolean,
    origin_port_charges boolean,
    forwarders_fee boolean,
    origin_vessel_loading boolean,
    destination_port_charges boolean,
    destination_customs boolean,
    destination_loading boolean,
    destination_labour boolean,
    destination_warehousing boolean
);


--
-- Name: incoterm_charges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.incoterm_charges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: incoterm_charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.incoterm_charges_id_seq OWNED BY public.incoterm_charges.id;


--
-- Name: incoterm_liabilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.incoterm_liabilities (
    id bigint NOT NULL,
    pre_carriage boolean,
    on_carriage boolean,
    freight boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    origin_warehousing boolean,
    origin_labour boolean,
    origin_packing boolean,
    origin_loading boolean,
    origin_customs boolean,
    origin_port_charges boolean,
    forwarders_fee boolean,
    origin_vessel_loading boolean,
    destination_port_charges boolean,
    destination_customs boolean,
    destination_loading boolean,
    destination_labour boolean,
    destination_warehousing boolean
);


--
-- Name: incoterm_liabilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.incoterm_liabilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: incoterm_liabilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.incoterm_liabilities_id_seq OWNED BY public.incoterm_liabilities.id;


--
-- Name: incoterm_scopes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.incoterm_scopes (
    id bigint NOT NULL,
    pre_carriage boolean,
    on_carriage boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    mode_of_transport boolean
);


--
-- Name: incoterm_scopes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.incoterm_scopes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: incoterm_scopes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.incoterm_scopes_id_seq OWNED BY public.incoterm_scopes.id;


--
-- Name: incoterms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.incoterms (
    id bigint NOT NULL,
    code character varying,
    description character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    seller_incoterm_scope_id integer,
    seller_incoterm_liability_id integer,
    seller_incoterm_charge_id integer,
    buyer_incoterm_scope_id integer,
    buyer_incoterm_liability_id integer,
    buyer_incoterm_charge_id integer
);


--
-- Name: incoterms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.incoterms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: incoterms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.incoterms_id_seq OWNED BY public.incoterms.id;


--
-- Name: itineraries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.itineraries (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying,
    mode_of_transport character varying,
    tenant_id integer,
    sandbox_id uuid,
    transshipment character varying,
    origin_hub_id bigint,
    destination_hub_id bigint,
    organization_id uuid
);


--
-- Name: itineraries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.itineraries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: itineraries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.itineraries_id_seq OWNED BY public.itineraries.id;


--
-- Name: journey_cargo_units; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journey_cargo_units (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    query_id uuid,
    quantity integer DEFAULT 1 NOT NULL,
    stackable boolean NOT NULL,
    cargo_class character varying NOT NULL,
    weight_unit character varying DEFAULT 'kg'::character varying NOT NULL,
    width_unit character varying DEFAULT 'm'::character varying NOT NULL,
    length_unit character varying DEFAULT 'm'::character varying NOT NULL,
    height_unit character varying DEFAULT 'm'::character varying NOT NULL,
    weight_value numeric(20,5) DEFAULT 0.0 NOT NULL,
    width_value numeric(20,5) DEFAULT 0.0 NOT NULL,
    length_value numeric(20,5) DEFAULT 0.0 NOT NULL,
    height_value numeric(20,5) DEFAULT 0.0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    colli_type public.journey_colli_type,
    CONSTRAINT journey_cargo_units_cargo_class_presence CHECK (((cargo_class IS NOT NULL) AND ((cargo_class)::text !~ '^\s*$'::text))),
    CONSTRAINT journey_cargo_units_height_unit_presence CHECK (((height_unit IS NOT NULL) AND ((height_unit)::text !~ '^\s*$'::text))),
    CONSTRAINT journey_cargo_units_height_value_numericality CHECK ((height_value >= (0)::numeric)),
    CONSTRAINT journey_cargo_units_length_unit_presence CHECK (((length_unit IS NOT NULL) AND ((length_unit)::text !~ '^\s*$'::text))),
    CONSTRAINT journey_cargo_units_length_value_numericality CHECK ((length_value >= (0)::numeric)),
    CONSTRAINT journey_cargo_units_quantity_numericality CHECK ((quantity > 0)),
    CONSTRAINT journey_cargo_units_weight_unit_presence CHECK (((weight_unit IS NOT NULL) AND ((weight_unit)::text !~ '^\s*$'::text))),
    CONSTRAINT journey_cargo_units_weight_value_numericality CHECK ((weight_value > (0)::numeric)),
    CONSTRAINT journey_cargo_units_width_unit_presence CHECK (((width_unit IS NOT NULL) AND ((width_unit)::text !~ '^\s*$'::text))),
    CONSTRAINT journey_cargo_units_width_value_numericality CHECK ((width_value >= (0)::numeric))
);


--
-- Name: journey_commodity_infos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journey_commodity_infos (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    cargo_unit_id uuid,
    hs_code character varying,
    imo_class character varying DEFAULT ''::character varying NOT NULL,
    description character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    CONSTRAINT journey_commodity_infos_description_presence CHECK (((description IS NOT NULL) AND ((description)::text !~ '^\s*$'::text)))
);


--
-- Name: journey_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journey_contacts (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    shipment_request_id uuid,
    original_id uuid NOT NULL,
    function character varying NOT NULL,
    company_name character varying DEFAULT ''::character varying NOT NULL,
    name character varying NOT NULL,
    phone character varying DEFAULT ''::character varying NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    point public.geometry(Geometry,4326) NOT NULL,
    geocoded_address character varying,
    address_line_1 character varying DEFAULT ''::character varying NOT NULL,
    address_line_2 character varying DEFAULT ''::character varying NOT NULL,
    address_line_3 character varying DEFAULT ''::character varying NOT NULL,
    postal_code character varying DEFAULT ''::character varying NOT NULL,
    city character varying DEFAULT ''::character varying NOT NULL,
    country_code character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    CONSTRAINT journey_contacts_city_presence CHECK (((city IS NOT NULL) AND ((city)::text !~ '^\s*$'::text))),
    CONSTRAINT journey_contacts_company_name_presence CHECK (((company_name IS NOT NULL) AND ((company_name)::text !~ '^\s*$'::text))),
    CONSTRAINT journey_contacts_country_code_length CHECK ((length((country_code)::text) = 2)),
    CONSTRAINT journey_contacts_country_code_presence CHECK (((country_code IS NOT NULL) AND ((country_code)::text !~ '^\s*$'::text))),
    CONSTRAINT journey_contacts_email_presence CHECK (((email IS NOT NULL) AND ((email)::text !~ '^\s*$'::text))),
    CONSTRAINT journey_contacts_name_presence CHECK (((name IS NOT NULL) AND ((name)::text !~ '^\s*$'::text))),
    CONSTRAINT journey_contacts_phone_presence CHECK (((phone IS NOT NULL) AND ((phone)::text !~ '^\s*$'::text)))
);


--
-- Name: journey_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journey_documents (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    shipment_request_id uuid,
    query_id uuid,
    kind public.journey_document_type,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: journey_errors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journey_errors (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    result_set_id uuid,
    cargo_unit_id uuid,
    code integer,
    service character varying,
    carrier character varying,
    mode_of_transport character varying,
    property character varying,
    value character varying,
    "limit" character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: journey_line_item_cargo_units; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journey_line_item_cargo_units (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    line_item_id uuid,
    cargo_unit_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: journey_line_item_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journey_line_item_sets (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    shipment_request_id uuid,
    result_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: journey_line_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journey_line_items (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    route_section_id uuid,
    route_point_id uuid,
    line_item_set_id uuid,
    note character varying DEFAULT ''::character varying NOT NULL,
    "order" integer NOT NULL,
    fee_code character varying NOT NULL,
    description character varying DEFAULT ''::character varying NOT NULL,
    total_cents integer,
    total_currency character varying,
    unit_price_cents integer,
    unit_price_currency character varying,
    units integer NOT NULL,
    included boolean DEFAULT false,
    optional boolean DEFAULT false,
    wm_rate numeric NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    CONSTRAINT journey_line_items_fee_code_presence CHECK (((fee_code IS NOT NULL) AND ((fee_code)::text !~ '^\s*$'::text))),
    CONSTRAINT journey_line_items_units_numericality CHECK ((units > 0)),
    CONSTRAINT journey_line_items_wm_rate_numericality CHECK ((wm_rate > (0)::numeric))
);


--
-- Name: journey_offer_line_item_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journey_offer_line_item_sets (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    offer_id uuid,
    line_item_set_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: journey_offer_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journey_offer_results (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    offer_id uuid,
    result_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: journey_offers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journey_offers (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    query_id uuid
);


--
-- Name: journey_queries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journey_queries (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    organization_id uuid,
    creator_id uuid,
    client_id uuid,
    company_id uuid,
    source_id uuid NOT NULL,
    origin character varying NOT NULL,
    destination character varying NOT NULL,
    origin_coordinates public.geometry(Geometry,4326) NOT NULL,
    destination_coordinates public.geometry(Geometry,4326) NOT NULL,
    customs boolean DEFAULT false,
    insurance boolean DEFAULT false,
    cargo_ready_date timestamp without time zone NOT NULL,
    delivery_date timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    creator_type character varying,
    billable boolean DEFAULT false,
    load_type public.journey_load_type,
    CONSTRAINT delivery_after_cargo_ready_date CHECK ((delivery_date > cargo_ready_date)),
    CONSTRAINT journey_queries_destination_coordinates_presence CHECK (((destination_coordinates IS NOT NULL) AND ((destination_coordinates)::text !~ '^\s*$'::text))),
    CONSTRAINT journey_queries_destination_presence CHECK (((destination IS NOT NULL) AND ((destination)::text !~ '^\s*$'::text))),
    CONSTRAINT journey_queries_origin_coordinates_presence CHECK (((origin_coordinates IS NOT NULL) AND ((origin_coordinates)::text !~ '^\s*$'::text))),
    CONSTRAINT journey_queries_origin_presence CHECK (((origin IS NOT NULL) AND ((origin)::text !~ '^\s*$'::text)))
);


--
-- Name: journey_result_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journey_result_sets (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    query_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    currency character varying NOT NULL,
    status public.journey_status,
    CONSTRAINT journey_result_sets_currency_presence CHECK (((currency IS NOT NULL) AND ((currency)::text !~ '^\s*$'::text)))
);


--
-- Name: journey_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journey_results (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    result_set_id uuid,
    expiration_date timestamp without time zone NOT NULL,
    issued_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: journey_route_points; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journey_route_points (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    function character varying NOT NULL,
    name character varying NOT NULL,
    coordinates public.geometry NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    locode character varying,
    geo_id character varying,
    CONSTRAINT journey_route_points_function_presence CHECK (((function IS NOT NULL) AND ((function)::text !~ '^\s*$'::text))),
    CONSTRAINT journey_route_points_name_presence CHECK (((name IS NOT NULL) AND ((name)::text !~ '^\s*$'::text)))
);


--
-- Name: journey_route_sections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journey_route_sections (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    from_id uuid,
    to_id uuid,
    result_id uuid,
    carrier character varying NOT NULL,
    service character varying NOT NULL,
    "order" integer NOT NULL,
    mode_of_transport public.journey_mode_of_transport,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    transit_time integer NOT NULL,
    CONSTRAINT journey_route_sections_carrier_presence CHECK (((carrier IS NOT NULL) AND ((carrier)::text !~ '^\s*$'::text))),
    CONSTRAINT journey_route_sections_service_presence CHECK (((service IS NOT NULL) AND ((service)::text !~ '^\s*$'::text)))
);


--
-- Name: journey_shipment_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journey_shipment_requests (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    result_id uuid,
    client_id uuid,
    preferred_voyage character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    company_id uuid,
    CONSTRAINT journey_shipment_requests_preferred_voyage_presence CHECK (((preferred_voyage IS NOT NULL) AND ((preferred_voyage)::text !~ '^\s*$'::text)))
);


--
-- Name: journey_shipments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journey_shipments (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    shipment_request_id uuid,
    creator_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: layovers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.layovers (
    id bigint NOT NULL,
    stop_id integer,
    eta timestamp without time zone,
    etd timestamp without time zone,
    stop_index integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    itinerary_id integer,
    trip_id integer,
    closing_date timestamp without time zone,
    sandbox_id uuid
);


--
-- Name: layovers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.layovers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: layovers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.layovers_id_seq OWNED BY public.layovers.id;


--
-- Name: ledger_delta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ledger_delta (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    amount_cents bigint DEFAULT 0 NOT NULL,
    amount_currency character varying NOT NULL,
    fee_id uuid,
    rate_basis integer DEFAULT 0 NOT NULL,
    kg_range numrange,
    stowage_range numrange,
    km_range numrange,
    cbm_range numrange,
    wm_range numrange,
    unit_range numrange,
    min_amount_cents bigint DEFAULT 0 NOT NULL,
    min_amount_currency character varying NOT NULL,
    max_amount_cents bigint DEFAULT 0 NOT NULL,
    max_amount_currency character varying NOT NULL,
    wm_ratio numeric DEFAULT 1000,
    operator integer DEFAULT 0 NOT NULL,
    level integer DEFAULT 0 NOT NULL,
    target_type character varying,
    target_id uuid,
    validity daterange,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ledger_fees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ledger_fees (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    cargo_class bigint DEFAULT 0,
    cargo_type bigint DEFAULT 0,
    category integer DEFAULT 0,
    code character varying,
    rate_id uuid,
    action integer DEFAULT 0,
    base numeric DEFAULT 0.0000010,
    "order" integer DEFAULT 0,
    applicable integer DEFAULT 0,
    load_meterage_limit numeric DEFAULT 0.0,
    load_meterage_type integer DEFAULT 0,
    load_meterage_logic integer DEFAULT 0,
    load_meterage_ratio numeric DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ledger_rates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ledger_rates (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    target_type character varying,
    target_id uuid,
    location_id uuid,
    terminal_id uuid,
    tenant_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization_id uuid
);


--
-- Name: legacy_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_addresses (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: legacy_aggregated_cargos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_aggregated_cargos (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: legacy_cargo_item_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_cargo_item_types (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: legacy_cargo_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_cargo_items (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: legacy_charge_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_charge_categories (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: legacy_containers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_containers (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: legacy_contents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_contents (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    component character varying,
    index integer,
    section character varying,
    tenant_id integer,
    text jsonb DEFAULT '{}'::jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization_id uuid
);


--
-- Name: legacy_countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_countries (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: legacy_currencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_currencies (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: legacy_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_files (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    approval_details jsonb,
    approved character varying,
    doc_type character varying,
    quotation_id integer,
    sandbox_id uuid,
    shipment_id integer,
    tenant_id integer,
    text character varying,
    url character varying,
    legacy_user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id uuid,
    organization_id uuid,
    target_type character varying,
    target_id uuid,
    user_type character varying
);


--
-- Name: legacy_hubs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_hubs (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: legacy_itineraries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_itineraries (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: legacy_layovers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_layovers (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: legacy_local_charges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_local_charges (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: legacy_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_roles (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: legacy_shipments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_shipments (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: legacy_stops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_stops (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: legacy_tenant_vehicles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_tenant_vehicles (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: legacy_transit_times; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_transit_times (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    tenant_vehicle_id integer,
    itinerary_id integer,
    duration integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: legacy_trips; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_trips (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: legacy_vehicles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_vehicles (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: local_charges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.local_charges (
    id bigint NOT NULL,
    mode_of_transport character varying,
    load_type character varying,
    hub_id integer,
    tenant_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tenant_vehicle_id integer,
    counterpart_hub_id integer,
    direction character varying,
    fees jsonb,
    dangerous boolean DEFAULT false,
    effective_date timestamp without time zone,
    expiration_date timestamp without time zone,
    legacy_user_id integer,
    uuid uuid DEFAULT public.gen_random_uuid(),
    sandbox_id uuid,
    group_id uuid,
    internal boolean DEFAULT false,
    metadata jsonb DEFAULT '{}'::jsonb,
    validity daterange,
    organization_id uuid,
    user_id uuid
);


--
-- Name: local_charges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.local_charges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: local_charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.local_charges_id_seq OWNED BY public.local_charges.id;


--
-- Name: locations_locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locations_locations (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    bounds public.geometry(Geometry,4326),
    osm_id bigint,
    name character varying,
    admin_level integer,
    country_code character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: locations_names; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locations_names (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    language character varying,
    location_id uuid,
    osm_id bigint,
    place_rank bigint,
    importance bigint,
    osm_type character varying,
    street character varying,
    city character varying,
    osm_class character varying,
    name_type character varying,
    country character varying,
    county character varying,
    state character varying,
    country_code character varying,
    display_name character varying,
    alternative_names character varying,
    name character varying,
    point public.geometry,
    postal_code character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    locode character varying
);


--
-- Name: mandatory_charges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mandatory_charges (
    id bigint NOT NULL,
    pre_carriage boolean,
    on_carriage boolean,
    import_charges boolean,
    export_charges boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: mandatory_charges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mandatory_charges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mandatory_charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mandatory_charges_id_seq OWNED BY public.mandatory_charges.id;


--
-- Name: map_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.map_data (
    id bigint NOT NULL,
    line jsonb,
    geo_json jsonb,
    origin numeric[] DEFAULT '{}'::numeric[],
    destination numeric[] DEFAULT '{}'::numeric[],
    itinerary_id character varying,
    tenant_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sandbox_id uuid,
    organization_id uuid
);


--
-- Name: map_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.map_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: map_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.map_data_id_seq OWNED BY public.map_data.id;


--
-- Name: max_dimensions_bundles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.max_dimensions_bundles (
    id bigint NOT NULL,
    mode_of_transport character varying,
    tenant_id integer,
    aggregate boolean,
    dimension_x numeric,
    dimension_y numeric,
    dimension_z numeric,
    payload_in_kg numeric,
    chargeable_weight numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sandbox_id uuid,
    carrier_id bigint,
    tenant_vehicle_id bigint,
    cargo_class character varying,
    itinerary_id bigint,
    width numeric,
    length numeric,
    height numeric,
    volume numeric DEFAULT 1000,
    organization_id uuid
);


--
-- Name: max_dimensions_bundles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.max_dimensions_bundles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: max_dimensions_bundles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.max_dimensions_bundles_id_seq OWNED BY public.max_dimensions_bundles.id;


--
-- Name: nexuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nexuses (
    id bigint NOT NULL,
    name character varying,
    tenant_id integer,
    latitude double precision,
    longitude double precision,
    photo character varying,
    country_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sandbox_id uuid,
    locode character varying,
    organization_id uuid
);


--
-- Name: nexuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nexuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nexuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nexuses_id_seq OWNED BY public.nexuses.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notes (
    id bigint NOT NULL,
    itinerary_id integer,
    hub_id integer,
    trucking_pricing_id integer,
    body character varying,
    header character varying,
    level character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sandbox_id uuid,
    target_type character varying,
    target_id integer,
    pricings_pricing_id uuid,
    tenant_id integer,
    contains_html boolean,
    transshipment boolean DEFAULT false NOT NULL,
    remarks boolean DEFAULT false NOT NULL,
    organization_id uuid
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notes_id_seq OWNED BY public.notes.id;


--
-- Name: notifications_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications_subscriptions (
    id bigint NOT NULL,
    event_type character varying,
    filter json DEFAULT '"{}"'::json,
    user_id uuid,
    organization_id uuid,
    email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: notifications_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_subscriptions_id_seq OWNED BY public.notifications_subscriptions.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_grants (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    resource_owner_id uuid NOT NULL,
    application_id uuid NOT NULL,
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying
);


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_tokens (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    resource_owner_id uuid,
    application_id uuid,
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    scopes character varying,
    previous_refresh_token character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: oauth_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_applications (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    redirect_uri text NOT NULL,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    confidential boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    owner_id uuid,
    owner_type character varying
);


--
-- Name: organizations_domains; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations_domains (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    domain character varying,
    organization_id uuid,
    "default" boolean DEFAULT false NOT NULL,
    aliases character varying[],
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: organizations_integration_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations_integration_tokens (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    organization_id uuid,
    token uuid,
    scope character varying,
    description character varying,
    expires_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: organizations_organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations_organizations (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    slug character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    live boolean DEFAULT false
);


--
-- Name: organizations_saml_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations_saml_metadata (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    organization_id uuid,
    content text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: organizations_scopes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations_scopes (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    target_type character varying,
    target_id uuid,
    content jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: organizations_themes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations_themes (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    organization_id uuid,
    name character varying,
    welcome_text character varying,
    primary_color character varying,
    secondary_color character varying,
    bright_primary_color character varying,
    bright_secondary_color character varying,
    emails jsonb DEFAULT '{}'::jsonb,
    phones jsonb DEFAULT '{}'::jsonb,
    addresses jsonb DEFAULT '{}'::jsonb,
    email_links jsonb DEFAULT '{}'::jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    websites jsonb DEFAULT '{}'::jsonb
);


--
-- Name: ports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ports (
    id bigint NOT NULL,
    country_id integer,
    name character varying,
    latitude numeric,
    longitude numeric,
    telephone character varying,
    web character varying,
    code character varying,
    nexus_id integer,
    address_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ports_id_seq OWNED BY public.ports.id;


--
-- Name: prices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prices (
    id bigint NOT NULL,
    value numeric,
    currency character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sandbox_id uuid
);


--
-- Name: prices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.prices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: prices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.prices_id_seq OWNED BY public.prices.id;


--
-- Name: pricings_breakdowns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pricings_breakdowns (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    metadatum_id uuid NOT NULL,
    pricing_id character varying,
    cargo_class character varying,
    margin_id uuid,
    data jsonb,
    target_type character varying,
    target_id uuid,
    cargo_unit_type character varying,
    cargo_unit_id bigint,
    charge_category_id integer,
    charge_id integer,
    rate_origin jsonb DEFAULT '{}'::jsonb,
    "order" integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    source_type character varying,
    source_id uuid,
    line_item_id uuid
);


--
-- Name: pricings_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pricings_details (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    tenant_id uuid,
    margin_id uuid,
    value numeric,
    operator character varying,
    charge_category_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sandbox_id uuid,
    organization_id uuid
);


--
-- Name: pricings_fees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pricings_fees (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    rate numeric,
    base numeric,
    rate_basis_id uuid,
    min numeric,
    hw_threshold numeric,
    hw_rate_basis_id uuid,
    charge_category_id integer,
    range jsonb DEFAULT '[]'::jsonb,
    currency_name character varying,
    currency_id bigint,
    pricing_id uuid,
    tenant_id bigint,
    legacy_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sandbox_id uuid,
    metadata jsonb DEFAULT '{}'::jsonb,
    organization_id uuid
);


--
-- Name: pricings_margins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pricings_margins (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    tenant_id uuid,
    pricing_id uuid,
    default_for character varying,
    operator character varying,
    value numeric,
    effective_date timestamp without time zone,
    expiration_date timestamp without time zone,
    applicable_type character varying,
    applicable_id uuid,
    tenant_vehicle_id integer,
    cargo_class character varying,
    itinerary_id integer,
    origin_hub_id integer,
    destination_hub_id integer,
    application_order integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    margin_type integer,
    sandbox_id uuid,
    validity daterange,
    organization_id uuid
);


--
-- Name: pricings_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pricings_metadata (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    pricing_id uuid,
    charge_breakdown_id integer,
    cargo_unit_id integer,
    tenant_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization_id uuid,
    result_id uuid
);


--
-- Name: pricings_pricings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pricings_pricings (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    wm_rate numeric,
    effective_date timestamp without time zone,
    expiration_date timestamp without time zone,
    tenant_id bigint,
    cargo_class character varying,
    load_type character varying,
    legacy_user_id bigint,
    itinerary_id bigint,
    tenant_vehicle_id integer,
    legacy_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sandbox_id uuid,
    internal boolean DEFAULT false,
    group_id uuid,
    validity daterange,
    transshipment character varying,
    organization_id uuid,
    user_id uuid
);


--
-- Name: pricings_rate_bases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pricings_rate_bases (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    external_code character varying,
    internal_code character varying,
    description character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sandbox_id uuid
);


--
-- Name: quotations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quotations (
    id bigint NOT NULL,
    target_email character varying,
    legacy_user_id integer,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_shipment_id integer,
    sandbox_id uuid,
    user_id uuid,
    distinct_id uuid,
    billing integer DEFAULT 0
);


--
-- Name: quotations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.quotations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quotations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.quotations_id_seq OWNED BY public.quotations.id;


--
-- Name: quotations_line_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quotations_line_items (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    tender_id uuid,
    charge_category_id bigint,
    amount_cents integer,
    amount_currency character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    section integer,
    cargo_type character varying,
    cargo_id integer,
    original_amount_cents integer,
    original_amount_currency character varying
);


--
-- Name: quotations_quotations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quotations_quotations (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    legacy_user_id bigint,
    tenant_id uuid,
    origin_nexus_id integer,
    destination_nexus_id integer,
    selected_date timestamp without time zone,
    sandbox_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    pickup_address_id integer,
    delivery_address_id integer,
    tenants_user_id uuid,
    legacy_shipment_id integer,
    shipment_id integer,
    billing integer DEFAULT 0,
    organization_id uuid,
    user_id uuid,
    completed boolean DEFAULT false,
    error_class character varying,
    creator_id uuid,
    estimated boolean,
    creator_type character varying
);


--
-- Name: quotations_tenders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quotations_tenders (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    tenant_vehicle_id bigint,
    origin_hub_id integer,
    destination_hub_id integer,
    carrier_name character varying,
    name character varying,
    load_type character varying,
    amount_cents integer,
    amount_currency character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    quotation_id uuid,
    itinerary_id integer,
    transshipment character varying,
    original_amount_cents integer,
    original_amount_currency character varying,
    pickup_tenant_vehicle_id integer,
    delivery_tenant_vehicle_id integer,
    pickup_truck_type character varying,
    delivery_truck_type character varying,
    imc_reference character varying
);


--
-- Name: rate_bases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rate_bases (
    id bigint NOT NULL,
    external_code character varying,
    internal_code character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: rate_bases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rate_bases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rate_bases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rate_bases_id_seq OWNED BY public.rate_bases.id;


--
-- Name: rates_cargos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rates_cargos (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    section_id uuid,
    cargo_class integer DEFAULT 0,
    cargo_type integer DEFAULT 0,
    category integer DEFAULT 0,
    code character varying,
    valid_at integer,
    operator integer,
    applicable_to integer DEFAULT 0,
    cbm_ratio numeric,
    "order" integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: rates_discounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rates_discounts (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    organization_id uuid,
    target_type character varying,
    target_id uuid,
    cargo_class integer DEFAULT 0,
    cargo_type integer DEFAULT 0,
    applicable_to_type character varying,
    applicable_to_id uuid,
    operator integer,
    amount_cents bigint DEFAULT 0 NOT NULL,
    amount_currency character varying NOT NULL,
    percentage numeric,
    rate_basis integer DEFAULT 0 NOT NULL,
    kg_range numrange,
    stowage_range numrange,
    km_range numrange,
    cbm_range numrange,
    wm_range numrange,
    unit_range numrange,
    min_amount_cents bigint DEFAULT 0 NOT NULL,
    min_amount_currency character varying NOT NULL,
    max_amount_cents bigint DEFAULT 0 NOT NULL,
    max_amount_currency character varying NOT NULL,
    cbm_ratio numeric DEFAULT 1000,
    validity daterange,
    "order" integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: rates_fees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rates_fees (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    cargo_id uuid,
    amount_cents bigint DEFAULT 0 NOT NULL,
    amount_currency character varying NOT NULL,
    rate_basis integer DEFAULT 0 NOT NULL,
    kg_range numrange,
    stowage_range numrange,
    km_range numrange,
    cbm_range numrange,
    wm_range numrange,
    unit_range numrange,
    min_amount_cents bigint DEFAULT 0 NOT NULL,
    min_amount_currency character varying NOT NULL,
    max_amount_cents bigint DEFAULT 0 NOT NULL,
    max_amount_currency character varying NOT NULL,
    cbm_ratio numeric DEFAULT 1000,
    operator integer DEFAULT 0 NOT NULL,
    level integer DEFAULT 0 NOT NULL,
    rule jsonb,
    validity daterange,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    percentage numeric
);


--
-- Name: rates_margins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rates_margins (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    organization_id uuid,
    target_type character varying,
    target_id uuid,
    cargo_class integer DEFAULT 0,
    cargo_type integer DEFAULT 0,
    applicable_to_type character varying,
    applicable_to_id uuid,
    operator integer,
    amount_cents bigint DEFAULT 0 NOT NULL,
    amount_currency character varying NOT NULL,
    percentage numeric,
    rate_basis integer DEFAULT 0 NOT NULL,
    kg_range numrange,
    stowage_range numrange,
    km_range numrange,
    cbm_range numrange,
    wm_range numrange,
    unit_range numrange,
    min_amount_cents bigint DEFAULT 0 NOT NULL,
    min_amount_currency character varying NOT NULL,
    max_amount_cents bigint DEFAULT 0 NOT NULL,
    max_amount_currency character varying NOT NULL,
    cbm_ratio numeric DEFAULT 1000,
    validity daterange,
    "order" integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: rates_sections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rates_sections (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    target_type character varying,
    target_id uuid,
    tenant_id uuid,
    location_id uuid,
    terminal_id uuid,
    carrier_id bigint,
    mode_of_transport integer,
    ldm_threshold_applicable integer,
    ldm_measurement integer,
    ldm_ratio numeric DEFAULT 0,
    ldm_threshold numeric DEFAULT 0.0,
    disabled boolean,
    ldm_area_divisor numeric,
    truck_height numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization_id uuid,
    applicable_to_type character varying,
    applicable_to_id uuid
);


--
-- Name: remarks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.remarks (
    id bigint NOT NULL,
    tenant_id bigint,
    category character varying,
    subcategory character varying,
    body character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "order" integer,
    sandbox_id uuid,
    organization_id uuid
);


--
-- Name: remarks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.remarks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: remarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.remarks_id_seq OWNED BY public.remarks.id;


--
-- Name: rms_data_books; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rms_data_books (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    sheet_type integer,
    tenant_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb,
    target_type character varying,
    target_id uuid,
    book_type integer DEFAULT 0 NOT NULL,
    organization_id uuid
);


--
-- Name: rms_data_cells; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rms_data_cells (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    tenant_id uuid,
    "row" integer,
    "column" integer,
    value character varying,
    sheet_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization_id uuid
);


--
-- Name: rms_data_sheets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rms_data_sheets (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    sheet_index integer,
    tenant_id uuid,
    book_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying,
    metadata jsonb DEFAULT '{}'::jsonb,
    organization_id uuid
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: routing_carriers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.routing_carriers (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying,
    abbreviated_name character varying,
    code character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: routing_line_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.routing_line_services (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying,
    carrier_id uuid,
    category integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: routing_locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.routing_locations (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    locode character varying,
    center public.geometry,
    bounds public.geometry,
    name character varying,
    country_code character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: routing_route_line_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.routing_route_line_services (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    route_id uuid,
    line_service_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    transit_time integer
);


--
-- Name: routing_routes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.routing_routes (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    origin_id uuid,
    destination_id uuid,
    allowed_cargo integer DEFAULT 0 NOT NULL,
    mode_of_transport integer DEFAULT 0 NOT NULL,
    price_factor numeric,
    time_factor numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    origin_terminal_id uuid,
    destination_terminal_id uuid
);


--
-- Name: routing_terminals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.routing_terminals (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    location_id uuid,
    center public.geometry,
    terminal_code character varying,
    "default" boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    mode_of_transport integer DEFAULT 0
);


--
-- Name: schema_migration_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migration_details (
    id bigint NOT NULL,
    version character varying NOT NULL,
    name character varying,
    hostname character varying,
    git_version character varying,
    rails_version character varying,
    duration integer,
    direction character varying,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: schema_migration_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.schema_migration_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schema_migration_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.schema_migration_details_id_seq OWNED BY public.schema_migration_details.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sequential_sequences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sequential_sequences (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    value bigint DEFAULT 0,
    name integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: shipment_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipment_contacts (
    id bigint NOT NULL,
    shipment_id integer,
    contact_id integer,
    contact_type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sandbox_id uuid
);


--
-- Name: shipment_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shipment_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shipment_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shipment_contacts_id_seq OWNED BY public.shipment_contacts.id;


--
-- Name: shipments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipments (
    id bigint NOT NULL,
    legacy_user_id integer,
    uuid character varying,
    imc_reference character varying,
    status character varying,
    load_type character varying,
    planned_pickup_date timestamp without time zone,
    has_pre_carriage boolean,
    has_on_carriage boolean,
    cargo_notes character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tenant_id integer,
    planned_eta timestamp without time zone,
    planned_etd timestamp without time zone,
    itinerary_id integer,
    trucking jsonb,
    customs_credit boolean DEFAULT false,
    total_goods_value jsonb,
    trip_id integer,
    eori character varying,
    direction character varying,
    notes character varying,
    origin_hub_id integer,
    destination_hub_id integer,
    booking_placed_at timestamp without time zone,
    insurance jsonb,
    customs jsonb,
    incoterm_id integer,
    closing_date timestamp without time zone,
    incoterm_text character varying,
    origin_nexus_id integer,
    destination_nexus_id integer,
    planned_origin_drop_off_date timestamp without time zone,
    quotation_id integer,
    planned_delivery_date timestamp without time zone,
    planned_destination_collection_date timestamp without time zone,
    desired_start_date timestamp without time zone,
    meta jsonb DEFAULT '{}'::jsonb,
    sandbox_id uuid,
    tender_id uuid,
    deleted_at timestamp without time zone,
    organization_id uuid,
    user_id uuid,
    distinct_id uuid,
    billing integer DEFAULT 0
);


--
-- Name: shipments_cargos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipments_cargos (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    sandbox_id uuid,
    shipment_id uuid,
    tenant_id uuid,
    total_goods_value_cents integer DEFAULT 0 NOT NULL,
    total_goods_value_currency character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization_id uuid
);


--
-- Name: shipments_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipments_contacts (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    shipment_id uuid NOT NULL,
    sandbox_id uuid,
    contact_type integer,
    latitude double precision,
    longitude double precision,
    company_name character varying,
    first_name character varying,
    last_name character varying,
    phone character varying,
    email character varying,
    geocoded_address character varying,
    street character varying,
    street_number character varying,
    post_code character varying,
    city character varying,
    province character varying,
    premise character varying,
    country_code character varying,
    country_name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: shipments_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipments_documents (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    attachable_type character varying NOT NULL,
    attachable_id uuid NOT NULL,
    sandbox_id uuid,
    doc_type integer,
    file_name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: shipments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shipments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shipments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shipments_id_seq OWNED BY public.shipments.id;


--
-- Name: shipments_invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipments_invoices (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    sandbox_id uuid,
    shipment_id uuid NOT NULL,
    invoice_number bigint,
    amount_cents integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: shipments_line_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipments_line_items (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    amount_cents integer DEFAULT 0 NOT NULL,
    amount_currency character varying NOT NULL,
    fee_code character varying,
    cargo_id uuid,
    invoice_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: shipments_shipment_request_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipments_shipment_request_contacts (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    shipment_request_id uuid NOT NULL,
    contact_id uuid NOT NULL,
    type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: shipments_shipment_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipments_shipment_requests (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    status character varying,
    cargo_notes character varying,
    notes character varying,
    incoterm_text character varying,
    eori character varying,
    ref_number character varying NOT NULL,
    submitted_at timestamp without time zone,
    eta timestamp without time zone,
    etd timestamp without time zone,
    sandbox_id uuid,
    legacy_user_id uuid,
    tenant_id uuid,
    tender_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization_id uuid,
    user_id uuid,
    billing integer DEFAULT 0
);


--
-- Name: shipments_shipments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipments_shipments (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    shipment_request_id uuid,
    sandbox_id uuid,
    legacy_user_id uuid,
    origin_id uuid NOT NULL,
    destination_id uuid NOT NULL,
    tenant_id uuid,
    status character varying,
    notes character varying,
    incoterm_text character varying,
    eori character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization_id uuid,
    user_id uuid
);


--
-- Name: shipments_units; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipments_units (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    sandbox_id uuid,
    cargo_id uuid NOT NULL,
    goods_value_cents integer DEFAULT 0 NOT NULL,
    goods_value_currency character varying NOT NULL,
    quantity integer NOT NULL,
    cargo_class bigint,
    cargo_type bigint,
    stackable boolean,
    dangerous_goods integer DEFAULT 0,
    weight_value numeric(100,3),
    weight_unit character varying DEFAULT 'kg'::character varying,
    width_value numeric(100,4),
    width_unit character varying DEFAULT 'm'::character varying,
    length_value numeric(100,4),
    length_unit character varying DEFAULT 'm'::character varying,
    height_value numeric(100,4),
    height_unit character varying DEFAULT 'm'::character varying,
    volume_value numeric(100,6),
    volume_unit character varying DEFAULT 'm3'::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: stops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stops (
    id bigint NOT NULL,
    hub_id integer,
    itinerary_id integer,
    index integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sandbox_id uuid
);


--
-- Name: stops_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stops_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stops_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stops_id_seq OWNED BY public.stops.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id bigint NOT NULL,
    tag_type character varying,
    name character varying,
    model character varying,
    model_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: tenant_cargo_item_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_cargo_item_types (
    id bigint NOT NULL,
    tenant_id bigint,
    cargo_item_type_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sandbox_id uuid,
    organization_id uuid
);


--
-- Name: tenant_cargo_item_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tenant_cargo_item_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tenant_cargo_item_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tenant_cargo_item_types_id_seq OWNED BY public.tenant_cargo_item_types.id;


--
-- Name: tenant_incoterms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_incoterms (
    id bigint NOT NULL,
    tenant_id integer,
    incoterm_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization_id uuid
);


--
-- Name: tenant_incoterms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tenant_incoterms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tenant_incoterms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tenant_incoterms_id_seq OWNED BY public.tenant_incoterms.id;


--
-- Name: tenant_routing_connections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_routing_connections (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    inbound_id uuid,
    outbound_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tenant_id uuid,
    mode_of_transport integer DEFAULT 0,
    line_service_id uuid,
    organization_id uuid
);


--
-- Name: tenant_routing_routes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_routing_routes (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    tenant_id uuid,
    route_id uuid,
    mode_of_transport integer DEFAULT 0,
    price_factor integer,
    time_factor integer,
    line_service_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    organization_id uuid
);


--
-- Name: tenant_routing_visibilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_routing_visibilities (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    target_type character varying,
    target_id uuid,
    connection_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tenant_vehicles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_vehicles (
    id bigint NOT NULL,
    vehicle_id integer,
    tenant_id integer,
    is_default boolean,
    mode_of_transport character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying,
    carrier_id integer,
    sandbox_id uuid,
    organization_id uuid,
    carrier_lock boolean DEFAULT false,
    deleted_at timestamp without time zone
);


--
-- Name: tenant_vehicles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tenant_vehicles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tenant_vehicles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tenant_vehicles_id_seq OWNED BY public.tenant_vehicles.id;


--
-- Name: tenants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants (
    id bigint NOT NULL,
    theme jsonb,
    emails jsonb,
    subdomain character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    phones jsonb,
    addresses jsonb,
    name character varying,
    scope jsonb,
    currency character varying DEFAULT 'EUR'::character varying,
    web jsonb,
    email_links jsonb
);


--
-- Name: tenants_companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants_companies (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying,
    address_id integer,
    vat_number character varying,
    email character varying,
    tenant_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    external_id character varying,
    phone character varying,
    sandbox_id uuid,
    deleted_at timestamp without time zone
);


--
-- Name: tenants_domains; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants_domains (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    tenant_id uuid,
    domain character varying,
    "default" boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tenants_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants_groups (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying,
    tenant_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sandbox_id uuid
);


--
-- Name: tenants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tenants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tenants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tenants_id_seq OWNED BY public.tenants.id;


--
-- Name: tenants_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants_memberships (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    member_type character varying,
    member_id uuid,
    group_id uuid,
    priority integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sandbox_id uuid
);


--
-- Name: tenants_saml_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants_saml_metadata (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    content character varying,
    tenant_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tenants_sandboxes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants_sandboxes (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    tenant_id uuid,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tenants_scopes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants_scopes (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    target_type character varying,
    target_id uuid,
    content jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sandbox_id uuid
);


--
-- Name: tenants_tenants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants_tenants (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    subdomain character varying,
    legacy_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    slug character varying
);


--
-- Name: tenants_themes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants_themes (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    tenant_id uuid,
    primary_color character varying,
    secondary_color character varying,
    bright_primary_color character varying,
    bright_secondary_color character varying,
    welcome_text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tenants_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants_users (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    email character varying NOT NULL,
    crypted_password character varying,
    salt character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    activation_state character varying,
    activation_token character varying,
    activation_token_expires_at timestamp without time zone,
    reset_password_token character varying,
    reset_password_token_expires_at timestamp without time zone,
    reset_password_email_sent_at timestamp without time zone,
    access_count_to_reset_password_page integer DEFAULT 0,
    last_login_at timestamp without time zone,
    last_logout_at timestamp without time zone,
    last_activity_at timestamp without time zone,
    last_login_from_ip_address character varying,
    failed_logins_count integer DEFAULT 0,
    lock_expires_at timestamp without time zone,
    unlock_token character varying,
    legacy_id integer,
    tenant_id uuid,
    company_id uuid,
    sandbox_id uuid,
    deleted_at timestamp without time zone
);


--
-- Name: treasury_exchange_rates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.treasury_exchange_rates (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    "from" character varying,
    "to" character varying,
    rate numeric,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: trips; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trips (
    id bigint NOT NULL,
    itinerary_id integer,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    voyage_code character varying,
    vessel character varying,
    tenant_vehicle_id integer,
    closing_date timestamp without time zone,
    load_type character varying,
    sandbox_id uuid
);


--
-- Name: trips_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trips_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trips_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trips_id_seq OWNED BY public.trips.id;


--
-- Name: trucking_couriers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trucking_couriers (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying,
    tenant_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sandbox_id uuid,
    organization_id uuid
);


--
-- Name: trucking_coverages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trucking_coverages (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    hub_id integer,
    bounds public.geometry,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sandbox_id uuid
);


--
-- Name: trucking_hub_availabilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trucking_hub_availabilities (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    hub_id integer,
    type_availability_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sandbox_id uuid,
    deleted_at timestamp without time zone
);


--
-- Name: trucking_locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trucking_locations (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    zipcode character varying,
    country_code character varying,
    city_name character varying,
    distance integer,
    location_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sandbox_id uuid,
    deleted_at timestamp without time zone,
    data character varying,
    query integer,
    country_id bigint
);


--
-- Name: trucking_rates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trucking_rates (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    load_meterage jsonb,
    cbm_ratio integer,
    modifier character varying,
    tenant_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    rates jsonb,
    fees jsonb,
    identifier_modifier character varying,
    scope_id uuid,
    organization_id uuid
);


--
-- Name: trucking_scopes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trucking_scopes (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    load_type character varying,
    cargo_class character varying,
    carriage character varying,
    courier_id uuid,
    truck_type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: trucking_truckings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trucking_truckings (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    hub_id integer,
    location_id uuid,
    rate_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    load_meterage jsonb,
    cbm_ratio integer,
    modifier character varying,
    tenant_id integer,
    rates jsonb,
    fees jsonb,
    identifier_modifier character varying,
    load_type character varying,
    cargo_class character varying,
    carriage character varying,
    courier_id uuid,
    truck_type character varying,
    legacy_user_id integer,
    parent_id uuid,
    group_id uuid,
    sandbox_id uuid,
    metadata jsonb DEFAULT '{}'::jsonb,
    organization_id uuid,
    user_id uuid,
    tenant_vehicle_id integer,
    deleted_at timestamp without time zone,
    validity daterange
);


--
-- Name: trucking_type_availabilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trucking_type_availabilities (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    load_type character varying,
    carriage character varying,
    truck_type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    query_method integer,
    sandbox_id uuid,
    country_id bigint,
    deleted_at timestamp without time zone
);


--
-- Name: user_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_addresses (
    id bigint NOT NULL,
    legacy_user_id integer,
    address_id integer,
    category character varying,
    "primary" boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone,
    user_id uuid
);


--
-- Name: user_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_addresses_id_seq OWNED BY public.user_addresses.id;


--
-- Name: user_managers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_managers (
    id bigint NOT NULL,
    manager_id integer,
    legacy_user_id integer,
    section character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id uuid
);


--
-- Name: user_managers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_managers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_managers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_managers_id_seq OWNED BY public.user_managers.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    provider character varying DEFAULT 'tenant_email'::character varying NOT NULL,
    uid character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    nickname character varying,
    image character varying,
    email character varying,
    tenant_id integer,
    tokens json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    role_id bigint,
    guest boolean DEFAULT false,
    currency character varying DEFAULT 'EUR'::character varying,
    vat_number character varying,
    allow_password_change boolean DEFAULT false NOT NULL,
    optin_status jsonb DEFAULT '{}'::jsonb,
    optin_status_id integer,
    external_id character varying,
    agency_id integer,
    internal boolean DEFAULT false,
    deleted_at timestamp without time zone,
    sandbox_id uuid,
    company_number character varying,
    organization_id uuid
);


--
-- Name: users_admins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_admins (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    email character varying NOT NULL,
    crypted_password character varying,
    salt character varying,
    last_login_at timestamp without time zone,
    last_activity_at timestamp without time zone,
    last_login_from_ip_address character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_authentications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_authentications (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    user_id uuid,
    provider character varying NOT NULL,
    uid character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_client_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_client_profiles (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    user_id uuid,
    first_name character varying,
    last_name character varying,
    company_name character varying,
    phone character varying,
    deleted_at timestamp without time zone,
    external_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_client_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_client_settings (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    user_id uuid,
    locale character varying DEFAULT 'en-GB'::character varying,
    language character varying DEFAULT 'en-GB'::character varying,
    currency character varying DEFAULT 'EUR'::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_clients (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    organization_id uuid,
    deleted_at timestamp without time zone,
    email character varying NOT NULL,
    crypted_password character varying,
    salt character varying,
    last_login_at timestamp without time zone,
    last_logout_at timestamp without time zone,
    last_activity_at timestamp without time zone,
    last_login_from_ip_address character varying,
    unlock_token character varying,
    failed_logins_count integer DEFAULT 0,
    lock_expires_at timestamp without time zone,
    magic_login_token character varying,
    magic_login_token_expires_at timestamp without time zone,
    magic_login_email_sent_at timestamp without time zone,
    reset_password_token character varying,
    reset_password_token_expires_at timestamp without time zone,
    reset_password_email_sent_at timestamp without time zone,
    access_count_to_reset_password_page integer DEFAULT 0,
    activation_token character varying,
    activation_state character varying,
    activation_token_expires_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: users_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_memberships (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    user_id uuid,
    organization_id uuid,
    role integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_profiles (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    first_name character varying DEFAULT ''::character varying NOT NULL,
    last_name character varying DEFAULT ''::character varying NOT NULL,
    company_name character varying,
    phone character varying,
    legacy_user_id uuid,
    deleted_at timestamp without time zone,
    external_id character varying,
    user_id uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: users_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_settings (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    user_id uuid,
    locale character varying DEFAULT 'en-GB'::character varying,
    language character varying DEFAULT 'en-GB'::character varying,
    currency character varying DEFAULT 'EUR'::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: users_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_users (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    type character varying,
    organization_id uuid,
    deleted_at timestamp without time zone,
    email character varying NOT NULL,
    crypted_password character varying,
    salt character varying,
    last_login_at timestamp without time zone,
    last_logout_at timestamp without time zone,
    last_activity_at timestamp without time zone,
    last_login_from_ip_address character varying,
    unlock_token character varying,
    failed_logins_count integer DEFAULT 0,
    lock_expires_at timestamp without time zone,
    magic_login_token character varying,
    magic_login_token_expires_at timestamp without time zone,
    magic_login_email_sent_at timestamp without time zone,
    reset_password_token character varying,
    reset_password_token_expires_at timestamp without time zone,
    reset_password_email_sent_at timestamp without time zone,
    access_count_to_reset_password_page integer DEFAULT 0,
    activation_token character varying,
    activation_state character varying,
    activation_token_expires_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: vehicles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicles (
    id bigint NOT NULL,
    name character varying,
    mode_of_transport character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: vehicles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vehicles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vehicles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vehicles_id_seq OWNED BY public.vehicles.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions (
    id bigint NOT NULL,
    item_type character varying NOT NULL,
    item_id integer NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp without time zone,
    object_changes jsonb
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: addons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addons ALTER COLUMN id SET DEFAULT nextval('public.addons_id_seq'::regclass);


--
-- Name: addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses ALTER COLUMN id SET DEFAULT nextval('public.addresses_id_seq'::regclass);


--
-- Name: agencies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agencies ALTER COLUMN id SET DEFAULT nextval('public.agencies_id_seq'::regclass);


--
-- Name: aggregated_cargos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aggregated_cargos ALTER COLUMN id SET DEFAULT nextval('public.aggregated_cargos_id_seq'::regclass);


--
-- Name: alternative_names id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alternative_names ALTER COLUMN id SET DEFAULT nextval('public.alternative_names_id_seq'::regclass);


--
-- Name: cargo_item_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cargo_item_types ALTER COLUMN id SET DEFAULT nextval('public.cargo_item_types_id_seq'::regclass);


--
-- Name: cargo_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cargo_items ALTER COLUMN id SET DEFAULT nextval('public.cargo_items_id_seq'::regclass);


--
-- Name: carriers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carriers ALTER COLUMN id SET DEFAULT nextval('public.carriers_id_seq'::regclass);


--
-- Name: charge_breakdowns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.charge_breakdowns ALTER COLUMN id SET DEFAULT nextval('public.charge_breakdowns_id_seq'::regclass);


--
-- Name: charge_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.charge_categories ALTER COLUMN id SET DEFAULT nextval('public.charge_categories_id_seq'::regclass);


--
-- Name: charges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.charges ALTER COLUMN id SET DEFAULT nextval('public.charges_id_seq'::regclass);


--
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- Name: containers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.containers ALTER COLUMN id SET DEFAULT nextval('public.containers_id_seq'::regclass);


--
-- Name: countries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries ALTER COLUMN id SET DEFAULT nextval('public.countries_id_seq'::regclass);


--
-- Name: currencies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currencies ALTER COLUMN id SET DEFAULT nextval('public.currencies_id_seq'::regclass);


--
-- Name: customs_fees id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customs_fees ALTER COLUMN id SET DEFAULT nextval('public.customs_fees_id_seq'::regclass);


--
-- Name: event_store_events_in_streams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_store_events_in_streams ALTER COLUMN id SET DEFAULT nextval('public.event_store_events_in_streams_id_seq'::regclass);


--
-- Name: exchange_rates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange_rates ALTER COLUMN id SET DEFAULT nextval('public.exchange_rates_id_seq'::regclass);


--
-- Name: hubs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hubs ALTER COLUMN id SET DEFAULT nextval('public.hubs_id_seq'::regclass);


--
-- Name: incoterm_charges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incoterm_charges ALTER COLUMN id SET DEFAULT nextval('public.incoterm_charges_id_seq'::regclass);


--
-- Name: incoterm_liabilities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incoterm_liabilities ALTER COLUMN id SET DEFAULT nextval('public.incoterm_liabilities_id_seq'::regclass);


--
-- Name: incoterm_scopes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incoterm_scopes ALTER COLUMN id SET DEFAULT nextval('public.incoterm_scopes_id_seq'::regclass);


--
-- Name: incoterms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incoterms ALTER COLUMN id SET DEFAULT nextval('public.incoterms_id_seq'::regclass);


--
-- Name: itineraries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.itineraries ALTER COLUMN id SET DEFAULT nextval('public.itineraries_id_seq'::regclass);


--
-- Name: layovers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layovers ALTER COLUMN id SET DEFAULT nextval('public.layovers_id_seq'::regclass);


--
-- Name: local_charges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_charges ALTER COLUMN id SET DEFAULT nextval('public.local_charges_id_seq'::regclass);


--
-- Name: mandatory_charges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mandatory_charges ALTER COLUMN id SET DEFAULT nextval('public.mandatory_charges_id_seq'::regclass);


--
-- Name: map_data id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.map_data ALTER COLUMN id SET DEFAULT nextval('public.map_data_id_seq'::regclass);


--
-- Name: max_dimensions_bundles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.max_dimensions_bundles ALTER COLUMN id SET DEFAULT nextval('public.max_dimensions_bundles_id_seq'::regclass);


--
-- Name: nexuses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nexuses ALTER COLUMN id SET DEFAULT nextval('public.nexuses_id_seq'::regclass);


--
-- Name: notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes ALTER COLUMN id SET DEFAULT nextval('public.notes_id_seq'::regclass);


--
-- Name: notifications_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.notifications_subscriptions_id_seq'::regclass);


--
-- Name: ports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ports ALTER COLUMN id SET DEFAULT nextval('public.ports_id_seq'::regclass);


--
-- Name: prices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prices ALTER COLUMN id SET DEFAULT nextval('public.prices_id_seq'::regclass);


--
-- Name: quotations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotations ALTER COLUMN id SET DEFAULT nextval('public.quotations_id_seq'::regclass);


--
-- Name: rate_bases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rate_bases ALTER COLUMN id SET DEFAULT nextval('public.rate_bases_id_seq'::regclass);


--
-- Name: remarks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.remarks ALTER COLUMN id SET DEFAULT nextval('public.remarks_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: schema_migration_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migration_details ALTER COLUMN id SET DEFAULT nextval('public.schema_migration_details_id_seq'::regclass);


--
-- Name: shipment_contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipment_contacts ALTER COLUMN id SET DEFAULT nextval('public.shipment_contacts_id_seq'::regclass);


--
-- Name: shipments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments ALTER COLUMN id SET DEFAULT nextval('public.shipments_id_seq'::regclass);


--
-- Name: stops id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stops ALTER COLUMN id SET DEFAULT nextval('public.stops_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: tenant_cargo_item_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_cargo_item_types ALTER COLUMN id SET DEFAULT nextval('public.tenant_cargo_item_types_id_seq'::regclass);


--
-- Name: tenant_incoterms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_incoterms ALTER COLUMN id SET DEFAULT nextval('public.tenant_incoterms_id_seq'::regclass);


--
-- Name: tenant_vehicles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_vehicles ALTER COLUMN id SET DEFAULT nextval('public.tenant_vehicles_id_seq'::regclass);


--
-- Name: tenants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants ALTER COLUMN id SET DEFAULT nextval('public.tenants_id_seq'::regclass);


--
-- Name: trips id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trips ALTER COLUMN id SET DEFAULT nextval('public.trips_id_seq'::regclass);


--
-- Name: user_addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_addresses ALTER COLUMN id SET DEFAULT nextval('public.user_addresses_id_seq'::regclass);


--
-- Name: user_managers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_managers ALTER COLUMN id SET DEFAULT nextval('public.user_managers_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: vehicles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles ALTER COLUMN id SET DEFAULT nextval('public.vehicles_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: addons addons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addons
    ADD CONSTRAINT addons_pkey PRIMARY KEY (id);


--
-- Name: address_book_contacts address_book_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.address_book_contacts
    ADD CONSTRAINT address_book_contacts_pkey PRIMARY KEY (id);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: agencies agencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agencies
    ADD CONSTRAINT agencies_pkey PRIMARY KEY (id);


--
-- Name: aggregated_cargos aggregated_cargos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aggregated_cargos
    ADD CONSTRAINT aggregated_cargos_pkey PRIMARY KEY (id);


--
-- Name: alternative_names alternative_names_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alternative_names
    ADD CONSTRAINT alternative_names_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: cargo_units cargo_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cargo_units
    ADD CONSTRAINT cargo_groups_pkey PRIMARY KEY (id);


--
-- Name: cargo_item_types cargo_item_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cargo_item_types
    ADD CONSTRAINT cargo_item_types_pkey PRIMARY KEY (id);


--
-- Name: cargo_items cargo_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cargo_items
    ADD CONSTRAINT cargo_items_pkey PRIMARY KEY (id);


--
-- Name: cargo_cargos cargo_loads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cargo_cargos
    ADD CONSTRAINT cargo_loads_pkey PRIMARY KEY (id);


--
-- Name: carriers carriers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carriers
    ADD CONSTRAINT carriers_pkey PRIMARY KEY (id);


--
-- Name: charge_breakdowns charge_breakdowns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.charge_breakdowns
    ADD CONSTRAINT charge_breakdowns_pkey PRIMARY KEY (id);


--
-- Name: charge_categories charge_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.charge_categories
    ADD CONSTRAINT charge_categories_pkey PRIMARY KEY (id);


--
-- Name: charges charges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.charges
    ADD CONSTRAINT charges_pkey PRIMARY KEY (id);


--
-- Name: cms_data_widgets cms_data_widgets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cms_data_widgets
    ADD CONSTRAINT cms_data_widgets_pkey PRIMARY KEY (id);


--
-- Name: companies_companies companies_companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies_companies
    ADD CONSTRAINT companies_companies_pkey PRIMARY KEY (id);


--
-- Name: companies_memberships companies_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies_memberships
    ADD CONSTRAINT companies_memberships_pkey PRIMARY KEY (id);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: containers containers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.containers
    ADD CONSTRAINT containers_pkey PRIMARY KEY (id);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: currencies currencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currencies
    ADD CONSTRAINT currencies_pkey PRIMARY KEY (id);


--
-- Name: customs_fees customs_fees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customs_fees
    ADD CONSTRAINT customs_fees_pkey PRIMARY KEY (id);


--
-- Name: data_migrations data_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.data_migrations
    ADD CONSTRAINT data_migrations_pkey PRIMARY KEY (version);


--
-- Name: event_store_events_in_streams event_store_events_in_streams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_store_events_in_streams
    ADD CONSTRAINT event_store_events_in_streams_pkey PRIMARY KEY (id);


--
-- Name: event_store_events event_store_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_store_events
    ADD CONSTRAINT event_store_events_pkey PRIMARY KEY (id);


--
-- Name: exchange_rates exchange_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange_rates
    ADD CONSTRAINT exchange_rates_pkey PRIMARY KEY (id);


--
-- Name: groups_groups groups_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups_groups
    ADD CONSTRAINT groups_groups_pkey PRIMARY KEY (id);


--
-- Name: groups_memberships groups_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups_memberships
    ADD CONSTRAINT groups_memberships_pkey PRIMARY KEY (id);


--
-- Name: hubs hubs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hubs
    ADD CONSTRAINT hubs_pkey PRIMARY KEY (id);


--
-- Name: incoterm_charges incoterm_charges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incoterm_charges
    ADD CONSTRAINT incoterm_charges_pkey PRIMARY KEY (id);


--
-- Name: incoterm_liabilities incoterm_liabilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incoterm_liabilities
    ADD CONSTRAINT incoterm_liabilities_pkey PRIMARY KEY (id);


--
-- Name: incoterm_scopes incoterm_scopes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incoterm_scopes
    ADD CONSTRAINT incoterm_scopes_pkey PRIMARY KEY (id);


--
-- Name: incoterms incoterms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incoterms
    ADD CONSTRAINT incoterms_pkey PRIMARY KEY (id);


--
-- Name: itineraries itineraries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.itineraries
    ADD CONSTRAINT itineraries_pkey PRIMARY KEY (id);


--
-- Name: journey_cargo_units journey_cargo_units_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_cargo_units
    ADD CONSTRAINT journey_cargo_units_pkey PRIMARY KEY (id);


--
-- Name: journey_commodity_infos journey_commodity_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_commodity_infos
    ADD CONSTRAINT journey_commodity_infos_pkey PRIMARY KEY (id);


--
-- Name: journey_contacts journey_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_contacts
    ADD CONSTRAINT journey_contacts_pkey PRIMARY KEY (id);


--
-- Name: journey_documents journey_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_documents
    ADD CONSTRAINT journey_documents_pkey PRIMARY KEY (id);


--
-- Name: journey_errors journey_errors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_errors
    ADD CONSTRAINT journey_errors_pkey PRIMARY KEY (id);


--
-- Name: journey_line_item_cargo_units journey_line_item_cargo_units_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_line_item_cargo_units
    ADD CONSTRAINT journey_line_item_cargo_units_pkey PRIMARY KEY (id);


--
-- Name: journey_line_item_sets journey_line_item_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_line_item_sets
    ADD CONSTRAINT journey_line_item_sets_pkey PRIMARY KEY (id);


--
-- Name: journey_line_items journey_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_line_items
    ADD CONSTRAINT journey_line_items_pkey PRIMARY KEY (id);


--
-- Name: journey_offer_line_item_sets journey_offer_line_item_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_offer_line_item_sets
    ADD CONSTRAINT journey_offer_line_item_sets_pkey PRIMARY KEY (id);


--
-- Name: journey_offer_results journey_offer_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_offer_results
    ADD CONSTRAINT journey_offer_results_pkey PRIMARY KEY (id);


--
-- Name: journey_offers journey_offers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_offers
    ADD CONSTRAINT journey_offers_pkey PRIMARY KEY (id);


--
-- Name: journey_queries journey_queries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_queries
    ADD CONSTRAINT journey_queries_pkey PRIMARY KEY (id);


--
-- Name: journey_result_sets journey_result_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_result_sets
    ADD CONSTRAINT journey_result_sets_pkey PRIMARY KEY (id);


--
-- Name: journey_results journey_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_results
    ADD CONSTRAINT journey_results_pkey PRIMARY KEY (id);


--
-- Name: journey_route_points journey_route_points_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_route_points
    ADD CONSTRAINT journey_route_points_pkey PRIMARY KEY (id);


--
-- Name: journey_route_sections journey_route_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_route_sections
    ADD CONSTRAINT journey_route_sections_pkey PRIMARY KEY (id);


--
-- Name: journey_shipment_requests journey_shipment_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_shipment_requests
    ADD CONSTRAINT journey_shipment_requests_pkey PRIMARY KEY (id);


--
-- Name: journey_shipments journey_shipments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_shipments
    ADD CONSTRAINT journey_shipments_pkey PRIMARY KEY (id);


--
-- Name: layovers layovers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.layovers
    ADD CONSTRAINT layovers_pkey PRIMARY KEY (id);


--
-- Name: ledger_delta ledger_delta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ledger_delta
    ADD CONSTRAINT ledger_delta_pkey PRIMARY KEY (id);


--
-- Name: ledger_fees ledger_fees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ledger_fees
    ADD CONSTRAINT ledger_fees_pkey PRIMARY KEY (id);


--
-- Name: ledger_rates ledger_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ledger_rates
    ADD CONSTRAINT ledger_rates_pkey PRIMARY KEY (id);


--
-- Name: legacy_addresses legacy_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_addresses
    ADD CONSTRAINT legacy_addresses_pkey PRIMARY KEY (id);


--
-- Name: legacy_aggregated_cargos legacy_aggregated_cargos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_aggregated_cargos
    ADD CONSTRAINT legacy_aggregated_cargos_pkey PRIMARY KEY (id);


--
-- Name: legacy_cargo_item_types legacy_cargo_item_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_cargo_item_types
    ADD CONSTRAINT legacy_cargo_item_types_pkey PRIMARY KEY (id);


--
-- Name: legacy_cargo_items legacy_cargo_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_cargo_items
    ADD CONSTRAINT legacy_cargo_items_pkey PRIMARY KEY (id);


--
-- Name: legacy_charge_categories legacy_charge_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_charge_categories
    ADD CONSTRAINT legacy_charge_categories_pkey PRIMARY KEY (id);


--
-- Name: legacy_containers legacy_containers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_containers
    ADD CONSTRAINT legacy_containers_pkey PRIMARY KEY (id);


--
-- Name: legacy_contents legacy_contents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_contents
    ADD CONSTRAINT legacy_contents_pkey PRIMARY KEY (id);


--
-- Name: legacy_countries legacy_countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_countries
    ADD CONSTRAINT legacy_countries_pkey PRIMARY KEY (id);


--
-- Name: legacy_currencies legacy_currencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_currencies
    ADD CONSTRAINT legacy_currencies_pkey PRIMARY KEY (id);


--
-- Name: legacy_files legacy_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_files
    ADD CONSTRAINT legacy_files_pkey PRIMARY KEY (id);


--
-- Name: legacy_hubs legacy_hubs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_hubs
    ADD CONSTRAINT legacy_hubs_pkey PRIMARY KEY (id);


--
-- Name: legacy_itineraries legacy_itineraries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_itineraries
    ADD CONSTRAINT legacy_itineraries_pkey PRIMARY KEY (id);


--
-- Name: legacy_layovers legacy_layovers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_layovers
    ADD CONSTRAINT legacy_layovers_pkey PRIMARY KEY (id);


--
-- Name: legacy_local_charges legacy_local_charges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_local_charges
    ADD CONSTRAINT legacy_local_charges_pkey PRIMARY KEY (id);


--
-- Name: legacy_roles legacy_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_roles
    ADD CONSTRAINT legacy_roles_pkey PRIMARY KEY (id);


--
-- Name: legacy_shipments legacy_shipments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_shipments
    ADD CONSTRAINT legacy_shipments_pkey PRIMARY KEY (id);


--
-- Name: legacy_stops legacy_stops_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_stops
    ADD CONSTRAINT legacy_stops_pkey PRIMARY KEY (id);


--
-- Name: legacy_tenant_vehicles legacy_tenant_vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_tenant_vehicles
    ADD CONSTRAINT legacy_tenant_vehicles_pkey PRIMARY KEY (id);


--
-- Name: legacy_transit_times legacy_transit_times_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_transit_times
    ADD CONSTRAINT legacy_transit_times_pkey PRIMARY KEY (id);


--
-- Name: legacy_trips legacy_trips_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_trips
    ADD CONSTRAINT legacy_trips_pkey PRIMARY KEY (id);


--
-- Name: legacy_vehicles legacy_vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_vehicles
    ADD CONSTRAINT legacy_vehicles_pkey PRIMARY KEY (id);


--
-- Name: local_charges local_charges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_charges
    ADD CONSTRAINT local_charges_pkey PRIMARY KEY (id);


--
-- Name: locations_locations locations_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations_locations
    ADD CONSTRAINT locations_locations_pkey PRIMARY KEY (id);


--
-- Name: locations_names locations_names_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations_names
    ADD CONSTRAINT locations_names_pkey PRIMARY KEY (id);


--
-- Name: mandatory_charges mandatory_charges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mandatory_charges
    ADD CONSTRAINT mandatory_charges_pkey PRIMARY KEY (id);


--
-- Name: map_data map_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.map_data
    ADD CONSTRAINT map_data_pkey PRIMARY KEY (id);


--
-- Name: max_dimensions_bundles max_dimensions_bundles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.max_dimensions_bundles
    ADD CONSTRAINT max_dimensions_bundles_pkey PRIMARY KEY (id);


--
-- Name: nexuses nexuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nexuses
    ADD CONSTRAINT nexuses_pkey PRIMARY KEY (id);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: notifications_subscriptions notifications_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications_subscriptions
    ADD CONSTRAINT notifications_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants oauth_access_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications oauth_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: organizations_domains organizations_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations_domains
    ADD CONSTRAINT organizations_domains_pkey PRIMARY KEY (id);


--
-- Name: organizations_integration_tokens organizations_integration_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations_integration_tokens
    ADD CONSTRAINT organizations_integration_tokens_pkey PRIMARY KEY (id);


--
-- Name: users_memberships organizations_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_memberships
    ADD CONSTRAINT organizations_memberships_pkey PRIMARY KEY (id);


--
-- Name: organizations_organizations organizations_organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations_organizations
    ADD CONSTRAINT organizations_organizations_pkey PRIMARY KEY (id);


--
-- Name: organizations_saml_metadata organizations_saml_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations_saml_metadata
    ADD CONSTRAINT organizations_saml_metadata_pkey PRIMARY KEY (id);


--
-- Name: organizations_scopes organizations_scopes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations_scopes
    ADD CONSTRAINT organizations_scopes_pkey PRIMARY KEY (id);


--
-- Name: organizations_themes organizations_themes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations_themes
    ADD CONSTRAINT organizations_themes_pkey PRIMARY KEY (id);


--
-- Name: ports ports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ports
    ADD CONSTRAINT ports_pkey PRIMARY KEY (id);


--
-- Name: prices prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prices
    ADD CONSTRAINT prices_pkey PRIMARY KEY (id);


--
-- Name: pricings_breakdowns pricings_breakdowns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pricings_breakdowns
    ADD CONSTRAINT pricings_breakdowns_pkey PRIMARY KEY (id);


--
-- Name: pricings_details pricings_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pricings_details
    ADD CONSTRAINT pricings_details_pkey PRIMARY KEY (id);


--
-- Name: pricings_fees pricings_fees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pricings_fees
    ADD CONSTRAINT pricings_fees_pkey PRIMARY KEY (id);


--
-- Name: pricings_margins pricings_margins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pricings_margins
    ADD CONSTRAINT pricings_margins_pkey PRIMARY KEY (id);


--
-- Name: pricings_metadata pricings_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pricings_metadata
    ADD CONSTRAINT pricings_metadata_pkey PRIMARY KEY (id);


--
-- Name: pricings_pricings pricings_pricings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pricings_pricings
    ADD CONSTRAINT pricings_pricings_pkey PRIMARY KEY (id);


--
-- Name: pricings_rate_bases pricings_rate_bases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pricings_rate_bases
    ADD CONSTRAINT pricings_rate_bases_pkey PRIMARY KEY (id);


--
-- Name: users_profiles profiles_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_profiles
    ADD CONSTRAINT profiles_profiles_pkey PRIMARY KEY (id);


--
-- Name: quotations_line_items quotations_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotations_line_items
    ADD CONSTRAINT quotations_line_items_pkey PRIMARY KEY (id);


--
-- Name: quotations quotations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotations
    ADD CONSTRAINT quotations_pkey PRIMARY KEY (id);


--
-- Name: quotations_quotations quotations_quotations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotations_quotations
    ADD CONSTRAINT quotations_quotations_pkey PRIMARY KEY (id);


--
-- Name: quotations_tenders quotations_tenders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotations_tenders
    ADD CONSTRAINT quotations_tenders_pkey PRIMARY KEY (id);


--
-- Name: rate_bases rate_bases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rate_bases
    ADD CONSTRAINT rate_bases_pkey PRIMARY KEY (id);


--
-- Name: rates_cargos rates_cargos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rates_cargos
    ADD CONSTRAINT rates_cargos_pkey PRIMARY KEY (id);


--
-- Name: rates_discounts rates_discounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rates_discounts
    ADD CONSTRAINT rates_discounts_pkey PRIMARY KEY (id);


--
-- Name: rates_fees rates_fees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rates_fees
    ADD CONSTRAINT rates_fees_pkey PRIMARY KEY (id);


--
-- Name: rates_margins rates_margins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rates_margins
    ADD CONSTRAINT rates_margins_pkey PRIMARY KEY (id);


--
-- Name: rates_sections rates_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rates_sections
    ADD CONSTRAINT rates_sections_pkey PRIMARY KEY (id);


--
-- Name: remarks remarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.remarks
    ADD CONSTRAINT remarks_pkey PRIMARY KEY (id);


--
-- Name: rms_data_books rms_data_books_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rms_data_books
    ADD CONSTRAINT rms_data_books_pkey PRIMARY KEY (id);


--
-- Name: rms_data_cells rms_data_cells_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rms_data_cells
    ADD CONSTRAINT rms_data_cells_pkey PRIMARY KEY (id);


--
-- Name: rms_data_sheets rms_data_sheets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rms_data_sheets
    ADD CONSTRAINT rms_data_sheets_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: routing_carriers routing_carriers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.routing_carriers
    ADD CONSTRAINT routing_carriers_pkey PRIMARY KEY (id);


--
-- Name: routing_line_services routing_line_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.routing_line_services
    ADD CONSTRAINT routing_line_services_pkey PRIMARY KEY (id);


--
-- Name: routing_locations routing_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.routing_locations
    ADD CONSTRAINT routing_locations_pkey PRIMARY KEY (id);


--
-- Name: routing_route_line_services routing_route_line_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.routing_route_line_services
    ADD CONSTRAINT routing_route_line_services_pkey PRIMARY KEY (id);


--
-- Name: routing_routes routing_routes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.routing_routes
    ADD CONSTRAINT routing_routes_pkey PRIMARY KEY (id);


--
-- Name: routing_terminals routing_terminals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.routing_terminals
    ADD CONSTRAINT routing_terminals_pkey PRIMARY KEY (id);


--
-- Name: schema_migration_details schema_migration_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migration_details
    ADD CONSTRAINT schema_migration_details_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sequential_sequences sequential_sequences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sequential_sequences
    ADD CONSTRAINT sequential_sequences_pkey PRIMARY KEY (id);


--
-- Name: shipment_contacts shipment_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipment_contacts
    ADD CONSTRAINT shipment_contacts_pkey PRIMARY KEY (id);


--
-- Name: shipments_cargos shipments_cargos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments_cargos
    ADD CONSTRAINT shipments_cargos_pkey PRIMARY KEY (id);


--
-- Name: shipments_contacts shipments_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments_contacts
    ADD CONSTRAINT shipments_contacts_pkey PRIMARY KEY (id);


--
-- Name: shipments_documents shipments_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments_documents
    ADD CONSTRAINT shipments_documents_pkey PRIMARY KEY (id);


--
-- Name: shipments_invoices shipments_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments_invoices
    ADD CONSTRAINT shipments_invoices_pkey PRIMARY KEY (id);


--
-- Name: shipments_line_items shipments_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments_line_items
    ADD CONSTRAINT shipments_line_items_pkey PRIMARY KEY (id);


--
-- Name: shipments shipments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT shipments_pkey PRIMARY KEY (id);


--
-- Name: shipments_shipment_request_contacts shipments_shipment_request_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments_shipment_request_contacts
    ADD CONSTRAINT shipments_shipment_request_contacts_pkey PRIMARY KEY (id);


--
-- Name: shipments_shipment_requests shipments_shipment_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments_shipment_requests
    ADD CONSTRAINT shipments_shipment_requests_pkey PRIMARY KEY (id);


--
-- Name: shipments_shipments shipments_shipments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments_shipments
    ADD CONSTRAINT shipments_shipments_pkey PRIMARY KEY (id);


--
-- Name: shipments_units shipments_units_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments_units
    ADD CONSTRAINT shipments_units_pkey PRIMARY KEY (id);


--
-- Name: stops stops_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stops
    ADD CONSTRAINT stops_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: tenant_cargo_item_types tenant_cargo_item_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_cargo_item_types
    ADD CONSTRAINT tenant_cargo_item_types_pkey PRIMARY KEY (id);


--
-- Name: tenant_incoterms tenant_incoterms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_incoterms
    ADD CONSTRAINT tenant_incoterms_pkey PRIMARY KEY (id);


--
-- Name: tenant_routing_connections tenant_routing_connections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_routing_connections
    ADD CONSTRAINT tenant_routing_connections_pkey PRIMARY KEY (id);


--
-- Name: tenant_routing_routes tenant_routing_routes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_routing_routes
    ADD CONSTRAINT tenant_routing_routes_pkey PRIMARY KEY (id);


--
-- Name: tenant_routing_visibilities tenant_routing_visibilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_routing_visibilities
    ADD CONSTRAINT tenant_routing_visibilities_pkey PRIMARY KEY (id);


--
-- Name: tenant_vehicles tenant_vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_vehicles
    ADD CONSTRAINT tenant_vehicles_pkey PRIMARY KEY (id);


--
-- Name: tenant_vehicles tenant_vehicles_upsert; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_vehicles
    ADD CONSTRAINT tenant_vehicles_upsert EXCLUDE USING btree (organization_id WITH =, name WITH =, mode_of_transport WITH =, carrier_id WITH =) WHERE ((deleted_at IS NULL));


--
-- Name: tenants_companies tenants_companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants_companies
    ADD CONSTRAINT tenants_companies_pkey PRIMARY KEY (id);


--
-- Name: tenants_domains tenants_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants_domains
    ADD CONSTRAINT tenants_domains_pkey PRIMARY KEY (id);


--
-- Name: tenants_groups tenants_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants_groups
    ADD CONSTRAINT tenants_groups_pkey PRIMARY KEY (id);


--
-- Name: tenants_memberships tenants_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants_memberships
    ADD CONSTRAINT tenants_memberships_pkey PRIMARY KEY (id);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: tenants_saml_metadata tenants_saml_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants_saml_metadata
    ADD CONSTRAINT tenants_saml_metadata_pkey PRIMARY KEY (id);


--
-- Name: tenants_sandboxes tenants_sandboxes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants_sandboxes
    ADD CONSTRAINT tenants_sandboxes_pkey PRIMARY KEY (id);


--
-- Name: tenants_scopes tenants_scopes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants_scopes
    ADD CONSTRAINT tenants_scopes_pkey PRIMARY KEY (id);


--
-- Name: tenants_tenants tenants_tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants_tenants
    ADD CONSTRAINT tenants_tenants_pkey PRIMARY KEY (id);


--
-- Name: tenants_themes tenants_themes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants_themes
    ADD CONSTRAINT tenants_themes_pkey PRIMARY KEY (id);


--
-- Name: tenants_users tenants_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants_users
    ADD CONSTRAINT tenants_users_pkey PRIMARY KEY (id);


--
-- Name: treasury_exchange_rates treasury_exchange_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.treasury_exchange_rates
    ADD CONSTRAINT treasury_exchange_rates_pkey PRIMARY KEY (id);


--
-- Name: trips trips_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trips
    ADD CONSTRAINT trips_pkey PRIMARY KEY (id);


--
-- Name: trucking_couriers trucking_couriers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trucking_couriers
    ADD CONSTRAINT trucking_couriers_pkey PRIMARY KEY (id);


--
-- Name: trucking_coverages trucking_coverages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trucking_coverages
    ADD CONSTRAINT trucking_coverages_pkey PRIMARY KEY (id);


--
-- Name: trucking_hub_availabilities trucking_hub_availabilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trucking_hub_availabilities
    ADD CONSTRAINT trucking_hub_availabilities_pkey PRIMARY KEY (id);


--
-- Name: trucking_locations trucking_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trucking_locations
    ADD CONSTRAINT trucking_locations_pkey PRIMARY KEY (id);


--
-- Name: trucking_locations trucking_locations_upsert; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trucking_locations
    ADD CONSTRAINT trucking_locations_upsert UNIQUE (data, query, country_id, deleted_at);


--
-- Name: trucking_rates trucking_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trucking_rates
    ADD CONSTRAINT trucking_rates_pkey PRIMARY KEY (id);


--
-- Name: trucking_scopes trucking_scopes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trucking_scopes
    ADD CONSTRAINT trucking_scopes_pkey PRIMARY KEY (id);


--
-- Name: trucking_type_availabilities trucking_type_availabilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trucking_type_availabilities
    ADD CONSTRAINT trucking_type_availabilities_pkey PRIMARY KEY (id);


--
-- Name: trucking_truckings trucking_upsert; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trucking_truckings
    ADD CONSTRAINT trucking_upsert EXCLUDE USING gist (hub_id WITH =, carriage WITH =, load_type WITH =, cargo_class WITH =, location_id WITH =, organization_id WITH =, truck_type WITH =, group_id WITH =, tenant_vehicle_id WITH =, validity WITH &&) WHERE ((deleted_at IS NULL));


--
-- Name: trucking_truckings truckings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trucking_truckings
    ADD CONSTRAINT truckings_pkey PRIMARY KEY (id);


--
-- Name: user_addresses user_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_addresses
    ADD CONSTRAINT user_addresses_pkey PRIMARY KEY (id);


--
-- Name: user_managers user_managers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_managers
    ADD CONSTRAINT user_managers_pkey PRIMARY KEY (id);


--
-- Name: users_admins users_admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_admins
    ADD CONSTRAINT users_admins_pkey PRIMARY KEY (id);


--
-- Name: users_authentications users_authentications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_authentications
    ADD CONSTRAINT users_authentications_pkey PRIMARY KEY (id);


--
-- Name: users_client_profiles users_client_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_client_profiles
    ADD CONSTRAINT users_client_profiles_pkey PRIMARY KEY (id);


--
-- Name: users_client_settings users_client_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_client_settings
    ADD CONSTRAINT users_client_settings_pkey PRIMARY KEY (id);


--
-- Name: users_clients users_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_clients
    ADD CONSTRAINT users_clients_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users_settings users_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_settings
    ADD CONSTRAINT users_settings_pkey PRIMARY KEY (id);


--
-- Name: users_users users_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_users
    ADD CONSTRAINT users_users_pkey PRIMARY KEY (id);


--
-- Name: vehicles vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_addons_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_addons_on_organization_id ON public.addons USING btree (organization_id);


--
-- Name: index_addons_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_addons_on_tenant_id ON public.addons USING btree (tenant_id);


--
-- Name: index_address_book_contacts_on_legacy_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_address_book_contacts_on_legacy_user_id ON public.address_book_contacts USING btree (legacy_user_id);


--
-- Name: index_address_book_contacts_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_address_book_contacts_on_sandbox_id ON public.address_book_contacts USING btree (sandbox_id);


--
-- Name: index_address_book_contacts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_address_book_contacts_on_user_id ON public.address_book_contacts USING btree (user_id);


--
-- Name: index_addresses_on_point; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_addresses_on_point ON public.addresses USING gist (point);


--
-- Name: index_addresses_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_addresses_on_sandbox_id ON public.addresses USING btree (sandbox_id);


--
-- Name: index_agencies_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agencies_on_organization_id ON public.agencies USING btree (organization_id);


--
-- Name: index_agencies_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agencies_on_tenant_id ON public.agencies USING btree (tenant_id);


--
-- Name: index_aggregated_cargos_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_aggregated_cargos_on_sandbox_id ON public.aggregated_cargos USING btree (sandbox_id);


--
-- Name: index_cargo_cargos_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cargo_cargos_on_organization_id ON public.cargo_cargos USING btree (organization_id);


--
-- Name: index_cargo_cargos_on_quotation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cargo_cargos_on_quotation_id ON public.cargo_cargos USING btree (quotation_id);


--
-- Name: index_cargo_cargos_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cargo_cargos_on_tenant_id ON public.cargo_cargos USING btree (tenant_id);


--
-- Name: index_cargo_items_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cargo_items_on_sandbox_id ON public.cargo_items USING btree (sandbox_id);


--
-- Name: index_cargo_units_on_cargo_class; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cargo_units_on_cargo_class ON public.cargo_units USING btree (cargo_class);


--
-- Name: index_cargo_units_on_cargo_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cargo_units_on_cargo_id ON public.cargo_units USING btree (cargo_id);


--
-- Name: index_cargo_units_on_cargo_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cargo_units_on_cargo_type ON public.cargo_units USING btree (cargo_type);


--
-- Name: index_cargo_units_on_legacy_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cargo_units_on_legacy_id ON public.cargo_units USING btree (legacy_id);


--
-- Name: index_cargo_units_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cargo_units_on_organization_id ON public.cargo_units USING btree (organization_id);


--
-- Name: index_cargo_units_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cargo_units_on_tenant_id ON public.cargo_units USING btree (tenant_id);


--
-- Name: index_carriers_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_carriers_on_code ON public.carriers USING btree (code) WHERE (deleted_at IS NULL);


--
-- Name: index_carriers_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_carriers_on_sandbox_id ON public.carriers USING btree (sandbox_id);


--
-- Name: index_charge_breakdowns_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_charge_breakdowns_on_deleted_at ON public.charge_breakdowns USING btree (deleted_at);


--
-- Name: index_charge_breakdowns_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_charge_breakdowns_on_sandbox_id ON public.charge_breakdowns USING btree (sandbox_id);


--
-- Name: index_charge_categories_on_cargo_unit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_charge_categories_on_cargo_unit_id ON public.charge_categories USING btree (cargo_unit_id);


--
-- Name: index_charge_categories_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_charge_categories_on_code ON public.charge_categories USING btree (code);


--
-- Name: index_charge_categories_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_charge_categories_on_organization_id ON public.charge_categories USING btree (organization_id);


--
-- Name: index_charge_categories_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_charge_categories_on_sandbox_id ON public.charge_categories USING btree (sandbox_id);


--
-- Name: index_charge_categories_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_charge_categories_on_tenant_id ON public.charge_categories USING btree (tenant_id);


--
-- Name: index_charges_on_charge_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_charges_on_charge_category_id ON public.charges USING btree (charge_category_id);


--
-- Name: index_charges_on_children_charge_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_charges_on_children_charge_category_id ON public.charges USING btree (children_charge_category_id);


--
-- Name: index_charges_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_charges_on_deleted_at ON public.charges USING btree (deleted_at);


--
-- Name: index_charges_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_charges_on_parent_id ON public.charges USING btree (parent_id);


--
-- Name: index_charges_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_charges_on_sandbox_id ON public.charges USING btree (sandbox_id);


--
-- Name: index_cms_data_widgets_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cms_data_widgets_on_organization_id ON public.cms_data_widgets USING btree (organization_id);


--
-- Name: index_companies_companies_on_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_companies_on_address_id ON public.companies_companies USING btree (address_id);


--
-- Name: index_companies_companies_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_companies_on_organization_id ON public.companies_companies USING btree (organization_id);


--
-- Name: index_companies_companies_on_organization_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_companies_on_organization_id_and_name ON public.companies_companies USING btree (organization_id, name);


--
-- Name: index_companies_companies_on_tenants_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_companies_on_tenants_company_id ON public.companies_companies USING btree (tenants_company_id);


--
-- Name: index_companies_memberships_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_memberships_on_company_id ON public.companies_memberships USING btree (company_id);


--
-- Name: index_companies_memberships_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_memberships_on_deleted_at ON public.companies_memberships USING btree (deleted_at);


--
-- Name: index_companies_memberships_on_member_id_and_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_memberships_on_member_id_and_company_id ON public.companies_memberships USING btree (member_id, company_id);


--
-- Name: index_companies_memberships_on_member_type_and_member_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_memberships_on_member_type_and_member_id ON public.companies_memberships USING btree (member_type, member_id);


--
-- Name: index_contacts_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_sandbox_id ON public.contacts USING btree (sandbox_id);


--
-- Name: index_contacts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_user_id ON public.contacts USING btree (user_id);


--
-- Name: index_containers_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_containers_on_sandbox_id ON public.containers USING btree (sandbox_id);


--
-- Name: index_currencies_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_currencies_on_organization_id ON public.currencies USING btree (organization_id);


--
-- Name: index_currencies_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_currencies_on_tenant_id ON public.currencies USING btree (tenant_id);


--
-- Name: index_customs_fees_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_customs_fees_on_organization_id ON public.customs_fees USING btree (organization_id);


--
-- Name: index_customs_fees_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_customs_fees_on_tenant_id ON public.customs_fees USING btree (tenant_id);


--
-- Name: index_event_store_events_in_streams_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_store_events_in_streams_on_created_at ON public.event_store_events_in_streams USING btree (created_at);


--
-- Name: index_event_store_events_in_streams_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_store_events_in_streams_on_event_id ON public.event_store_events_in_streams USING btree (event_id);


--
-- Name: index_event_store_events_in_streams_on_stream_and_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_event_store_events_in_streams_on_stream_and_event_id ON public.event_store_events_in_streams USING btree (stream, event_id);


--
-- Name: index_event_store_events_in_streams_on_stream_and_position; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_event_store_events_in_streams_on_stream_and_position ON public.event_store_events_in_streams USING btree (stream, "position");


--
-- Name: index_event_store_events_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_store_events_on_created_at ON public.event_store_events USING btree (created_at);


--
-- Name: index_event_store_events_on_event_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_store_events_on_event_type ON public.event_store_events USING btree (event_type);


--
-- Name: index_exchange_rates_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_exchange_rates_on_created_at ON public.exchange_rates USING btree (created_at);


--
-- Name: index_exchange_rates_on_from; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_exchange_rates_on_from ON public.exchange_rates USING btree ("from");


--
-- Name: index_exchange_rates_on_to; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_exchange_rates_on_to ON public.exchange_rates USING btree ("to");


--
-- Name: index_groups_groups_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_groups_on_deleted_at ON public.groups_groups USING btree (deleted_at);


--
-- Name: index_groups_groups_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_groups_on_organization_id ON public.groups_groups USING btree (organization_id);


--
-- Name: index_groups_groups_on_tenants_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_groups_on_tenants_group_id ON public.groups_groups USING btree (tenants_group_id);


--
-- Name: index_groups_memberships_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_memberships_on_deleted_at ON public.groups_memberships USING btree (deleted_at);


--
-- Name: index_groups_memberships_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_memberships_on_group_id ON public.groups_memberships USING btree (group_id);


--
-- Name: index_groups_memberships_on_member_type_and_member_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_memberships_on_member_type_and_member_id ON public.groups_memberships USING btree (member_type, member_id);


--
-- Name: index_hubs_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hubs_on_organization_id ON public.hubs USING btree (organization_id);


--
-- Name: index_hubs_on_point; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hubs_on_point ON public.hubs USING gist (point);


--
-- Name: index_hubs_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hubs_on_sandbox_id ON public.hubs USING btree (sandbox_id);


--
-- Name: index_hubs_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hubs_on_tenant_id ON public.hubs USING btree (tenant_id);


--
-- Name: index_itineraries_on_destination_hub_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_itineraries_on_destination_hub_id ON public.itineraries USING btree (destination_hub_id);


--
-- Name: index_itineraries_on_mode_of_transport; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_itineraries_on_mode_of_transport ON public.itineraries USING btree (mode_of_transport);


--
-- Name: index_itineraries_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_itineraries_on_name ON public.itineraries USING btree (name);


--
-- Name: index_itineraries_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_itineraries_on_organization_id ON public.itineraries USING btree (organization_id);


--
-- Name: index_itineraries_on_origin_hub_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_itineraries_on_origin_hub_id ON public.itineraries USING btree (origin_hub_id);


--
-- Name: index_itineraries_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_itineraries_on_sandbox_id ON public.itineraries USING btree (sandbox_id);


--
-- Name: index_itineraries_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_itineraries_on_tenant_id ON public.itineraries USING btree (tenant_id);


--
-- Name: index_journey_cargo_units_on_query_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_cargo_units_on_query_id ON public.journey_cargo_units USING btree (query_id);


--
-- Name: index_journey_commodity_infos_on_cargo_unit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_commodity_infos_on_cargo_unit_id ON public.journey_commodity_infos USING btree (cargo_unit_id);


--
-- Name: index_journey_contacts_on_shipment_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_contacts_on_shipment_request_id ON public.journey_contacts USING btree (shipment_request_id);


--
-- Name: index_journey_documents_on_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_documents_on_kind ON public.journey_documents USING btree (kind);


--
-- Name: index_journey_documents_on_query_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_documents_on_query_id ON public.journey_documents USING btree (query_id);


--
-- Name: index_journey_documents_on_shipment_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_documents_on_shipment_request_id ON public.journey_documents USING btree (shipment_request_id);


--
-- Name: index_journey_errors_on_cargo_unit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_errors_on_cargo_unit_id ON public.journey_errors USING btree (cargo_unit_id);


--
-- Name: index_journey_errors_on_result_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_errors_on_result_set_id ON public.journey_errors USING btree (result_set_id);


--
-- Name: index_journey_line_item_cargo_units_on_cargo_unit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_line_item_cargo_units_on_cargo_unit_id ON public.journey_line_item_cargo_units USING btree (cargo_unit_id);


--
-- Name: index_journey_line_item_cargo_units_on_line_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_line_item_cargo_units_on_line_item_id ON public.journey_line_item_cargo_units USING btree (line_item_id);


--
-- Name: index_journey_line_item_sets_on_result_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_line_item_sets_on_result_id ON public.journey_line_item_sets USING btree (result_id);


--
-- Name: index_journey_line_item_sets_on_shipment_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_line_item_sets_on_shipment_request_id ON public.journey_line_item_sets USING btree (shipment_request_id);


--
-- Name: index_journey_line_items_on_line_item_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_line_items_on_line_item_set_id ON public.journey_line_items USING btree (line_item_set_id);


--
-- Name: index_journey_line_items_on_route_point_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_line_items_on_route_point_id ON public.journey_line_items USING btree (route_point_id);


--
-- Name: index_journey_line_items_on_route_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_line_items_on_route_section_id ON public.journey_line_items USING btree (route_section_id);


--
-- Name: index_journey_offer_line_item_sets_on_line_item_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_offer_line_item_sets_on_line_item_set_id ON public.journey_offer_line_item_sets USING btree (line_item_set_id);


--
-- Name: index_journey_offer_line_item_sets_on_offer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_offer_line_item_sets_on_offer_id ON public.journey_offer_line_item_sets USING btree (offer_id);


--
-- Name: index_journey_offer_results_on_offer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_offer_results_on_offer_id ON public.journey_offer_results USING btree (offer_id);


--
-- Name: index_journey_offer_results_on_result_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_offer_results_on_result_id ON public.journey_offer_results USING btree (result_id);


--
-- Name: index_journey_offers_on_query_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_offers_on_query_id ON public.journey_offers USING btree (query_id);


--
-- Name: index_journey_queries_on_billable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_queries_on_billable ON public.journey_queries USING btree (billable);


--
-- Name: index_journey_queries_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_queries_on_client_id ON public.journey_queries USING btree (client_id);


--
-- Name: index_journey_queries_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_queries_on_company_id ON public.journey_queries USING btree (company_id);


--
-- Name: index_journey_queries_on_creator_id_and_creator_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_queries_on_creator_id_and_creator_type ON public.journey_queries USING btree (creator_id, creator_type);


--
-- Name: index_journey_queries_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_queries_on_organization_id ON public.journey_queries USING btree (organization_id);


--
-- Name: index_journey_result_sets_on_query_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_result_sets_on_query_id ON public.journey_result_sets USING btree (query_id);


--
-- Name: index_journey_results_on_result_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_results_on_result_set_id ON public.journey_results USING btree (result_set_id);


--
-- Name: index_journey_route_sections_on_from_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_route_sections_on_from_id ON public.journey_route_sections USING btree (from_id);


--
-- Name: index_journey_route_sections_on_mode_of_transport; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_route_sections_on_mode_of_transport ON public.journey_route_sections USING btree (mode_of_transport);


--
-- Name: index_journey_route_sections_on_result_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_route_sections_on_result_id ON public.journey_route_sections USING btree (result_id);


--
-- Name: index_journey_route_sections_on_to_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_route_sections_on_to_id ON public.journey_route_sections USING btree (to_id);


--
-- Name: index_journey_shipment_requests_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_shipment_requests_on_client_id ON public.journey_shipment_requests USING btree (client_id);


--
-- Name: index_journey_shipment_requests_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_shipment_requests_on_company_id ON public.journey_shipment_requests USING btree (company_id);


--
-- Name: index_journey_shipment_requests_on_result_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_shipment_requests_on_result_id ON public.journey_shipment_requests USING btree (result_id);


--
-- Name: index_journey_shipments_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_shipments_on_creator_id ON public.journey_shipments USING btree (creator_id);


--
-- Name: index_journey_shipments_on_shipment_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_journey_shipments_on_shipment_request_id ON public.journey_shipments USING btree (shipment_request_id);


--
-- Name: index_layovers_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_layovers_on_sandbox_id ON public.layovers USING btree (sandbox_id);


--
-- Name: index_layovers_on_stop_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_layovers_on_stop_id ON public.layovers USING btree (stop_id);


--
-- Name: index_ledger_delta_on_cbm_range; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ledger_delta_on_cbm_range ON public.ledger_delta USING gist (cbm_range);


--
-- Name: index_ledger_delta_on_fee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ledger_delta_on_fee_id ON public.ledger_delta USING btree (fee_id);


--
-- Name: index_ledger_delta_on_kg_range; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ledger_delta_on_kg_range ON public.ledger_delta USING gist (kg_range);


--
-- Name: index_ledger_delta_on_km_range; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ledger_delta_on_km_range ON public.ledger_delta USING gist (km_range);


--
-- Name: index_ledger_delta_on_stowage_range; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ledger_delta_on_stowage_range ON public.ledger_delta USING gist (stowage_range);


--
-- Name: index_ledger_delta_on_unit_range; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ledger_delta_on_unit_range ON public.ledger_delta USING gist (unit_range);


--
-- Name: index_ledger_delta_on_validity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ledger_delta_on_validity ON public.ledger_delta USING gist (validity);


--
-- Name: index_ledger_delta_on_wm_range; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ledger_delta_on_wm_range ON public.ledger_delta USING gist (wm_range);


--
-- Name: index_ledger_fees_on_cargo_class; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ledger_fees_on_cargo_class ON public.ledger_fees USING btree (cargo_class);


--
-- Name: index_ledger_fees_on_cargo_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ledger_fees_on_cargo_type ON public.ledger_fees USING btree (cargo_type);


--
-- Name: index_ledger_fees_on_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ledger_fees_on_category ON public.ledger_fees USING btree (category);


--
-- Name: index_ledger_fees_on_rate_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ledger_fees_on_rate_id ON public.ledger_fees USING btree (rate_id);


--
-- Name: index_ledger_rates_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ledger_rates_on_location_id ON public.ledger_rates USING btree (location_id);


--
-- Name: index_ledger_rates_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ledger_rates_on_organization_id ON public.ledger_rates USING btree (organization_id);


--
-- Name: index_ledger_rates_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ledger_rates_on_tenant_id ON public.ledger_rates USING btree (tenant_id);


--
-- Name: index_ledger_rates_on_terminal_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ledger_rates_on_terminal_id ON public.ledger_rates USING btree (terminal_id);


--
-- Name: index_legacy_contents_on_component; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legacy_contents_on_component ON public.legacy_contents USING btree (component);


--
-- Name: index_legacy_contents_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legacy_contents_on_organization_id ON public.legacy_contents USING btree (organization_id);


--
-- Name: index_legacy_contents_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legacy_contents_on_tenant_id ON public.legacy_contents USING btree (tenant_id);


--
-- Name: index_legacy_files_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legacy_files_on_organization_id ON public.legacy_files USING btree (organization_id);


--
-- Name: index_legacy_files_on_quotation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legacy_files_on_quotation_id ON public.legacy_files USING btree (quotation_id);


--
-- Name: index_legacy_files_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legacy_files_on_sandbox_id ON public.legacy_files USING btree (sandbox_id);


--
-- Name: index_legacy_files_on_shipment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legacy_files_on_shipment_id ON public.legacy_files USING btree (shipment_id);


--
-- Name: index_legacy_files_on_target_type_and_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legacy_files_on_target_type_and_target_id ON public.legacy_files USING btree (target_type, target_id);


--
-- Name: index_legacy_files_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legacy_files_on_tenant_id ON public.legacy_files USING btree (tenant_id);


--
-- Name: index_legacy_files_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legacy_files_on_user_id ON public.legacy_files USING btree (user_id);


--
-- Name: index_legacy_files_on_user_id_and_user_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legacy_files_on_user_id_and_user_type ON public.legacy_files USING btree (user_id, user_type);


--
-- Name: index_legacy_transit_times_on_itinerary_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legacy_transit_times_on_itinerary_id ON public.legacy_transit_times USING btree (itinerary_id);


--
-- Name: index_legacy_transit_times_on_tenant_vehicle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legacy_transit_times_on_tenant_vehicle_id ON public.legacy_transit_times USING btree (tenant_vehicle_id);


--
-- Name: index_local_charges_on_direction; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_local_charges_on_direction ON public.local_charges USING btree (direction);


--
-- Name: index_local_charges_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_local_charges_on_group_id ON public.local_charges USING btree (group_id);


--
-- Name: index_local_charges_on_hub_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_local_charges_on_hub_id ON public.local_charges USING btree (hub_id);


--
-- Name: index_local_charges_on_load_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_local_charges_on_load_type ON public.local_charges USING btree (load_type);


--
-- Name: index_local_charges_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_local_charges_on_organization_id ON public.local_charges USING btree (organization_id);


--
-- Name: index_local_charges_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_local_charges_on_sandbox_id ON public.local_charges USING btree (sandbox_id);


--
-- Name: index_local_charges_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_local_charges_on_tenant_id ON public.local_charges USING btree (tenant_id);


--
-- Name: index_local_charges_on_tenant_vehicle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_local_charges_on_tenant_vehicle_id ON public.local_charges USING btree (tenant_vehicle_id);


--
-- Name: index_local_charges_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_local_charges_on_user_id ON public.local_charges USING btree (user_id);


--
-- Name: index_local_charges_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_local_charges_on_uuid ON public.local_charges USING btree (uuid);


--
-- Name: index_local_charges_on_validity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_local_charges_on_validity ON public.local_charges USING gist (validity);


--
-- Name: index_locations_locations_on_bounds; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_locations_on_bounds ON public.locations_locations USING gist (bounds);


--
-- Name: index_locations_locations_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_locations_on_deleted_at ON public.locations_locations USING btree (deleted_at);


--
-- Name: index_locations_locations_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_locations_on_name ON public.locations_locations USING btree (name);


--
-- Name: index_locations_locations_on_osm_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_locations_on_osm_id ON public.locations_locations USING btree (osm_id);


--
-- Name: index_locations_names_on_locode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_names_on_locode ON public.locations_names USING btree (locode);


--
-- Name: index_locations_names_on_osm_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_names_on_osm_id ON public.locations_names USING btree (osm_id);


--
-- Name: index_locations_names_on_osm_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_names_on_osm_type ON public.locations_names USING btree (osm_type);


--
-- Name: index_map_data_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_map_data_on_organization_id ON public.map_data USING btree (organization_id);


--
-- Name: index_map_data_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_map_data_on_sandbox_id ON public.map_data USING btree (sandbox_id);


--
-- Name: index_map_data_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_map_data_on_tenant_id ON public.map_data USING btree (tenant_id);


--
-- Name: index_max_dimensions_bundles_on_cargo_class; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_max_dimensions_bundles_on_cargo_class ON public.max_dimensions_bundles USING btree (cargo_class);


--
-- Name: index_max_dimensions_bundles_on_carrier_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_max_dimensions_bundles_on_carrier_id ON public.max_dimensions_bundles USING btree (carrier_id);


--
-- Name: index_max_dimensions_bundles_on_itinerary_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_max_dimensions_bundles_on_itinerary_id ON public.max_dimensions_bundles USING btree (itinerary_id);


--
-- Name: index_max_dimensions_bundles_on_mode_of_transport; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_max_dimensions_bundles_on_mode_of_transport ON public.max_dimensions_bundles USING btree (mode_of_transport);


--
-- Name: index_max_dimensions_bundles_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_max_dimensions_bundles_on_organization_id ON public.max_dimensions_bundles USING btree (organization_id);


--
-- Name: index_max_dimensions_bundles_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_max_dimensions_bundles_on_sandbox_id ON public.max_dimensions_bundles USING btree (sandbox_id);


--
-- Name: index_max_dimensions_bundles_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_max_dimensions_bundles_on_tenant_id ON public.max_dimensions_bundles USING btree (tenant_id);


--
-- Name: index_max_dimensions_bundles_on_tenant_vehicle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_max_dimensions_bundles_on_tenant_vehicle_id ON public.max_dimensions_bundles USING btree (tenant_vehicle_id);


--
-- Name: index_nexuses_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_nexuses_on_organization_id ON public.nexuses USING btree (organization_id);


--
-- Name: index_nexuses_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_nexuses_on_sandbox_id ON public.nexuses USING btree (sandbox_id);


--
-- Name: index_nexuses_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_nexuses_on_tenant_id ON public.nexuses USING btree (tenant_id);


--
-- Name: index_notes_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_organization_id ON public.notes USING btree (organization_id);


--
-- Name: index_notes_on_pricings_pricing_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_pricings_pricing_id ON public.notes USING btree (pricings_pricing_id);


--
-- Name: index_notes_on_remarks; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_remarks ON public.notes USING btree (remarks);


--
-- Name: index_notes_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_sandbox_id ON public.notes USING btree (sandbox_id);


--
-- Name: index_notes_on_target_type_and_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_target_type_and_target_id ON public.notes USING btree (target_type, target_id);


--
-- Name: index_notes_on_transshipment; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_transshipment ON public.notes USING btree (transshipment);


--
-- Name: index_notifications_subscriptions_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_subscriptions_on_email ON public.notifications_subscriptions USING btree (email);


--
-- Name: index_notifications_subscriptions_on_event_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_subscriptions_on_event_type ON public.notifications_subscriptions USING btree (event_type);


--
-- Name: index_notifications_subscriptions_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_subscriptions_on_organization_id ON public.notifications_subscriptions USING btree (organization_id);


--
-- Name: index_notifications_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_subscriptions_on_user_id ON public.notifications_subscriptions USING btree (user_id);


--
-- Name: index_oauth_access_grants_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_application_id ON public.oauth_access_grants USING btree (application_id);


--
-- Name: index_oauth_access_grants_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_resource_owner_id ON public.oauth_access_grants USING btree (resource_owner_id);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON public.oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_application_id ON public.oauth_access_tokens USING btree (application_id);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON public.oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON public.oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON public.oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_owner_id_and_owner_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_applications_on_owner_id_and_owner_type ON public.oauth_applications USING btree (owner_id, owner_type);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON public.oauth_applications USING btree (uid);


--
-- Name: index_organizations_domains_on_domain; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organizations_domains_on_domain ON public.organizations_domains USING btree (domain);


--
-- Name: index_organizations_domains_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organizations_domains_on_organization_id ON public.organizations_domains USING btree (organization_id);


--
-- Name: index_organizations_integration_tokens_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organizations_integration_tokens_on_organization_id ON public.organizations_integration_tokens USING btree (organization_id);


--
-- Name: index_organizations_organizations_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organizations_organizations_on_slug ON public.organizations_organizations USING btree (slug);


--
-- Name: index_organizations_saml_metadata_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organizations_saml_metadata_on_organization_id ON public.organizations_saml_metadata USING btree (organization_id);


--
-- Name: index_organizations_scopes_on_target_type_and_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organizations_scopes_on_target_type_and_target_id ON public.organizations_scopes USING btree (target_type, target_id);


--
-- Name: index_organizations_themes_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organizations_themes_on_organization_id ON public.organizations_themes USING btree (organization_id);


--
-- Name: index_prices_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_prices_on_sandbox_id ON public.prices USING btree (sandbox_id);


--
-- Name: index_pricings_breakdowns_on_cargo_unit_type_and_cargo_unit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_breakdowns_on_cargo_unit_type_and_cargo_unit_id ON public.pricings_breakdowns USING btree (cargo_unit_type, cargo_unit_id);


--
-- Name: index_pricings_breakdowns_on_charge_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_breakdowns_on_charge_category_id ON public.pricings_breakdowns USING btree (charge_category_id);


--
-- Name: index_pricings_breakdowns_on_charge_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_breakdowns_on_charge_id ON public.pricings_breakdowns USING btree (charge_id);


--
-- Name: index_pricings_breakdowns_on_margin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_breakdowns_on_margin_id ON public.pricings_breakdowns USING btree (margin_id);


--
-- Name: index_pricings_breakdowns_on_metadatum_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_breakdowns_on_metadatum_id ON public.pricings_breakdowns USING btree (metadatum_id);


--
-- Name: index_pricings_breakdowns_on_source_type_and_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_breakdowns_on_source_type_and_source_id ON public.pricings_breakdowns USING btree (source_type, source_id);


--
-- Name: index_pricings_breakdowns_on_target_type_and_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_breakdowns_on_target_type_and_target_id ON public.pricings_breakdowns USING btree (target_type, target_id);


--
-- Name: index_pricings_details_on_charge_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_details_on_charge_category_id ON public.pricings_details USING btree (charge_category_id);


--
-- Name: index_pricings_details_on_margin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_details_on_margin_id ON public.pricings_details USING btree (margin_id);


--
-- Name: index_pricings_details_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_details_on_organization_id ON public.pricings_details USING btree (organization_id);


--
-- Name: index_pricings_details_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_details_on_sandbox_id ON public.pricings_details USING btree (sandbox_id);


--
-- Name: index_pricings_details_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_details_on_tenant_id ON public.pricings_details USING btree (tenant_id);


--
-- Name: index_pricings_fees_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_fees_on_organization_id ON public.pricings_fees USING btree (organization_id);


--
-- Name: index_pricings_fees_on_pricing_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_fees_on_pricing_id ON public.pricings_fees USING btree (pricing_id);


--
-- Name: index_pricings_fees_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_fees_on_sandbox_id ON public.pricings_fees USING btree (sandbox_id);


--
-- Name: index_pricings_fees_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_fees_on_tenant_id ON public.pricings_fees USING btree (tenant_id);


--
-- Name: index_pricings_margins_on_applicable_type_and_applicable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_margins_on_applicable_type_and_applicable_id ON public.pricings_margins USING btree (applicable_type, applicable_id);


--
-- Name: index_pricings_margins_on_application_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_margins_on_application_order ON public.pricings_margins USING btree (application_order);


--
-- Name: index_pricings_margins_on_cargo_class; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_margins_on_cargo_class ON public.pricings_margins USING btree (cargo_class);


--
-- Name: index_pricings_margins_on_destination_hub_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_margins_on_destination_hub_id ON public.pricings_margins USING btree (destination_hub_id);


--
-- Name: index_pricings_margins_on_effective_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_margins_on_effective_date ON public.pricings_margins USING btree (effective_date);


--
-- Name: index_pricings_margins_on_expiration_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_margins_on_expiration_date ON public.pricings_margins USING btree (expiration_date);


--
-- Name: index_pricings_margins_on_itinerary_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_margins_on_itinerary_id ON public.pricings_margins USING btree (itinerary_id);


--
-- Name: index_pricings_margins_on_margin_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_margins_on_margin_type ON public.pricings_margins USING btree (margin_type);


--
-- Name: index_pricings_margins_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_margins_on_organization_id ON public.pricings_margins USING btree (organization_id);


--
-- Name: index_pricings_margins_on_origin_hub_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_margins_on_origin_hub_id ON public.pricings_margins USING btree (origin_hub_id);


--
-- Name: index_pricings_margins_on_pricing_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_margins_on_pricing_id ON public.pricings_margins USING btree (pricing_id);


--
-- Name: index_pricings_margins_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_margins_on_sandbox_id ON public.pricings_margins USING btree (sandbox_id);


--
-- Name: index_pricings_margins_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_margins_on_tenant_id ON public.pricings_margins USING btree (tenant_id);


--
-- Name: index_pricings_margins_on_tenant_vehicle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_margins_on_tenant_vehicle_id ON public.pricings_margins USING btree (tenant_vehicle_id);


--
-- Name: index_pricings_metadata_on_charge_breakdown_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_metadata_on_charge_breakdown_id ON public.pricings_metadata USING btree (charge_breakdown_id);


--
-- Name: index_pricings_metadata_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_metadata_on_organization_id ON public.pricings_metadata USING btree (organization_id);


--
-- Name: index_pricings_metadata_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_metadata_on_tenant_id ON public.pricings_metadata USING btree (tenant_id);


--
-- Name: index_pricings_pricings_on_cargo_class; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_pricings_on_cargo_class ON public.pricings_pricings USING btree (cargo_class);


--
-- Name: index_pricings_pricings_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_pricings_on_group_id ON public.pricings_pricings USING btree (group_id);


--
-- Name: index_pricings_pricings_on_itinerary_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_pricings_on_itinerary_id ON public.pricings_pricings USING btree (itinerary_id);


--
-- Name: index_pricings_pricings_on_legacy_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_pricings_on_legacy_user_id ON public.pricings_pricings USING btree (legacy_user_id);


--
-- Name: index_pricings_pricings_on_load_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_pricings_on_load_type ON public.pricings_pricings USING btree (load_type);


--
-- Name: index_pricings_pricings_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_pricings_on_organization_id ON public.pricings_pricings USING btree (organization_id);


--
-- Name: index_pricings_pricings_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_pricings_on_sandbox_id ON public.pricings_pricings USING btree (sandbox_id);


--
-- Name: index_pricings_pricings_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_pricings_on_tenant_id ON public.pricings_pricings USING btree (tenant_id);


--
-- Name: index_pricings_pricings_on_tenant_vehicle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_pricings_on_tenant_vehicle_id ON public.pricings_pricings USING btree (tenant_vehicle_id);


--
-- Name: index_pricings_pricings_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_pricings_on_user_id ON public.pricings_pricings USING btree (user_id);


--
-- Name: index_pricings_pricings_on_validity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_pricings_on_validity ON public.pricings_pricings USING gist (validity);


--
-- Name: index_pricings_rate_bases_on_external_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_rate_bases_on_external_code ON public.pricings_rate_bases USING btree (external_code);


--
-- Name: index_pricings_rate_bases_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pricings_rate_bases_on_sandbox_id ON public.pricings_rate_bases USING btree (sandbox_id);


--
-- Name: index_quotations_line_items_on_cargo_type_and_cargo_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotations_line_items_on_cargo_type_and_cargo_id ON public.quotations_line_items USING btree (cargo_type, cargo_id);


--
-- Name: index_quotations_line_items_on_charge_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotations_line_items_on_charge_category_id ON public.quotations_line_items USING btree (charge_category_id);


--
-- Name: index_quotations_line_items_on_tender_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotations_line_items_on_tender_id ON public.quotations_line_items USING btree (tender_id);


--
-- Name: index_quotations_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotations_on_sandbox_id ON public.quotations USING btree (sandbox_id);


--
-- Name: index_quotations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotations_on_user_id ON public.quotations USING btree (user_id);


--
-- Name: index_quotations_quotations_on_creator_id_and_creator_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotations_quotations_on_creator_id_and_creator_type ON public.quotations_quotations USING btree (creator_id, creator_type);


--
-- Name: index_quotations_quotations_on_destination_nexus_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotations_quotations_on_destination_nexus_id ON public.quotations_quotations USING btree (destination_nexus_id);


--
-- Name: index_quotations_quotations_on_legacy_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotations_quotations_on_legacy_user_id ON public.quotations_quotations USING btree (legacy_user_id);


--
-- Name: index_quotations_quotations_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotations_quotations_on_organization_id ON public.quotations_quotations USING btree (organization_id);


--
-- Name: index_quotations_quotations_on_origin_nexus_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotations_quotations_on_origin_nexus_id ON public.quotations_quotations USING btree (origin_nexus_id);


--
-- Name: index_quotations_quotations_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotations_quotations_on_sandbox_id ON public.quotations_quotations USING btree (sandbox_id);


--
-- Name: index_quotations_quotations_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotations_quotations_on_tenant_id ON public.quotations_quotations USING btree (tenant_id);


--
-- Name: index_quotations_quotations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotations_quotations_on_user_id ON public.quotations_quotations USING btree (user_id);


--
-- Name: index_quotations_tenders_on_delivery_tenant_vehicle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotations_tenders_on_delivery_tenant_vehicle_id ON public.quotations_tenders USING btree (delivery_tenant_vehicle_id);


--
-- Name: index_quotations_tenders_on_destination_hub_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotations_tenders_on_destination_hub_id ON public.quotations_tenders USING btree (destination_hub_id);


--
-- Name: index_quotations_tenders_on_origin_hub_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotations_tenders_on_origin_hub_id ON public.quotations_tenders USING btree (origin_hub_id);


--
-- Name: index_quotations_tenders_on_pickup_tenant_vehicle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotations_tenders_on_pickup_tenant_vehicle_id ON public.quotations_tenders USING btree (pickup_tenant_vehicle_id);


--
-- Name: index_quotations_tenders_on_quotation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotations_tenders_on_quotation_id ON public.quotations_tenders USING btree (quotation_id);


--
-- Name: index_quotations_tenders_on_tenant_vehicle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quotations_tenders_on_tenant_vehicle_id ON public.quotations_tenders USING btree (tenant_vehicle_id);


--
-- Name: index_rates_cargos_on_cargo_class; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rates_cargos_on_cargo_class ON public.rates_cargos USING btree (cargo_class);


--
-- Name: index_rates_cargos_on_cargo_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rates_cargos_on_cargo_type ON public.rates_cargos USING btree (cargo_type);


--
-- Name: index_rates_cargos_on_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rates_cargos_on_category ON public.rates_cargos USING btree (category);


--
-- Name: index_rates_cargos_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rates_cargos_on_section_id ON public.rates_cargos USING btree (section_id);


--
-- Name: index_rates_discounts_on_applicable_to_type_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rates_discounts_on_applicable_to_type_and_id ON public.rates_discounts USING btree (applicable_to_type, applicable_to_id);


--
-- Name: index_rates_discounts_on_cargo_class; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rates_discounts_on_cargo_class ON public.rates_discounts USING btree (cargo_class);


--
-- Name: index_rates_discounts_on_cargo_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rates_discounts_on_cargo_type ON public.rates_discounts USING btree (cargo_type);


--
-- Name: index_rates_discounts_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rates_discounts_on_organization_id ON public.rates_discounts USING btree (organization_id);


--
-- Name: index_rates_discounts_on_target_type_and_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rates_discounts_on_target_type_and_target_id ON public.rates_discounts USING btree (target_type, target_id);


--
-- Name: index_rates_fees_on_cargo_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rates_fees_on_cargo_id ON public.rates_fees USING btree (cargo_id);


--
-- Name: index_rates_margins_on_applicable_to_type_and_applicable_to_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rates_margins_on_applicable_to_type_and_applicable_to_id ON public.rates_margins USING btree (applicable_to_type, applicable_to_id);


--
-- Name: index_rates_margins_on_cargo_class; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rates_margins_on_cargo_class ON public.rates_margins USING btree (cargo_class);


--
-- Name: index_rates_margins_on_cargo_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rates_margins_on_cargo_type ON public.rates_margins USING btree (cargo_type);


--
-- Name: index_rates_margins_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rates_margins_on_organization_id ON public.rates_margins USING btree (organization_id);


--
-- Name: index_rates_margins_on_target_type_and_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rates_margins_on_target_type_and_target_id ON public.rates_margins USING btree (target_type, target_id);


--
-- Name: index_rates_sections_on_applicable_to_type_and_applicable_to_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rates_sections_on_applicable_to_type_and_applicable_to_id ON public.rates_sections USING btree (applicable_to_type, applicable_to_id);


--
-- Name: index_rates_sections_on_carrier_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rates_sections_on_carrier_id ON public.rates_sections USING btree (carrier_id);


--
-- Name: index_rates_sections_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rates_sections_on_location_id ON public.rates_sections USING btree (location_id);


--
-- Name: index_rates_sections_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rates_sections_on_organization_id ON public.rates_sections USING btree (organization_id);


--
-- Name: index_rates_sections_on_target_type_and_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rates_sections_on_target_type_and_target_id ON public.rates_sections USING btree (target_type, target_id);


--
-- Name: index_rates_sections_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rates_sections_on_tenant_id ON public.rates_sections USING btree (tenant_id);


--
-- Name: index_rates_sections_on_terminal_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rates_sections_on_terminal_id ON public.rates_sections USING btree (terminal_id);


--
-- Name: index_remarks_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_remarks_on_organization_id ON public.remarks USING btree (organization_id);


--
-- Name: index_remarks_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_remarks_on_sandbox_id ON public.remarks USING btree (sandbox_id);


--
-- Name: index_remarks_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_remarks_on_tenant_id ON public.remarks USING btree (tenant_id);


--
-- Name: index_rms_data_books_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rms_data_books_on_organization_id ON public.rms_data_books USING btree (organization_id);


--
-- Name: index_rms_data_books_on_sheet_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rms_data_books_on_sheet_type ON public.rms_data_books USING btree (sheet_type);


--
-- Name: index_rms_data_books_on_target_type_and_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rms_data_books_on_target_type_and_target_id ON public.rms_data_books USING btree (target_type, target_id);


--
-- Name: index_rms_data_books_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rms_data_books_on_tenant_id ON public.rms_data_books USING btree (tenant_id);


--
-- Name: index_rms_data_cells_on_column; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rms_data_cells_on_column ON public.rms_data_cells USING btree ("column");


--
-- Name: index_rms_data_cells_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rms_data_cells_on_organization_id ON public.rms_data_cells USING btree (organization_id);


--
-- Name: index_rms_data_cells_on_row; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rms_data_cells_on_row ON public.rms_data_cells USING btree ("row");


--
-- Name: index_rms_data_cells_on_sheet_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rms_data_cells_on_sheet_id ON public.rms_data_cells USING btree (sheet_id);


--
-- Name: index_rms_data_cells_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rms_data_cells_on_tenant_id ON public.rms_data_cells USING btree (tenant_id);


--
-- Name: index_rms_data_sheets_on_book_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rms_data_sheets_on_book_id ON public.rms_data_sheets USING btree (book_id);


--
-- Name: index_rms_data_sheets_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rms_data_sheets_on_organization_id ON public.rms_data_sheets USING btree (organization_id);


--
-- Name: index_rms_data_sheets_on_sheet_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rms_data_sheets_on_sheet_index ON public.rms_data_sheets USING btree (sheet_index);


--
-- Name: index_rms_data_sheets_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rms_data_sheets_on_tenant_id ON public.rms_data_sheets USING btree (tenant_id);


--
-- Name: index_routing_line_services_on_carrier_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_routing_line_services_on_carrier_id ON public.routing_line_services USING btree (carrier_id);


--
-- Name: index_routing_locations_on_bounds; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_routing_locations_on_bounds ON public.routing_locations USING gist (bounds);


--
-- Name: index_routing_locations_on_center; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_routing_locations_on_center ON public.routing_locations USING btree (center);


--
-- Name: index_routing_locations_on_locode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_routing_locations_on_locode ON public.routing_locations USING btree (locode);


--
-- Name: index_routing_terminals_on_center; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_routing_terminals_on_center ON public.routing_terminals USING btree (center);


--
-- Name: index_schema_migration_details_on_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_schema_migration_details_on_version ON public.schema_migration_details USING btree (version);


--
-- Name: index_shipment_contacts_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipment_contacts_on_sandbox_id ON public.shipment_contacts USING btree (sandbox_id);


--
-- Name: index_shipment_request_contacts_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipment_request_contacts_on_contact_id ON public.shipments_shipment_request_contacts USING btree (contact_id);


--
-- Name: index_shipment_request_contacts_on_shipment_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipment_request_contacts_on_shipment_request_id ON public.shipments_shipment_request_contacts USING btree (shipment_request_id);


--
-- Name: index_shipments_cargos_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_cargos_on_organization_id ON public.shipments_cargos USING btree (organization_id);


--
-- Name: index_shipments_cargos_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_cargos_on_sandbox_id ON public.shipments_cargos USING btree (sandbox_id);


--
-- Name: index_shipments_cargos_on_shipment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_cargos_on_shipment_id ON public.shipments_cargos USING btree (shipment_id);


--
-- Name: index_shipments_cargos_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_cargos_on_tenant_id ON public.shipments_cargos USING btree (tenant_id);


--
-- Name: index_shipments_contacts_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_contacts_on_sandbox_id ON public.shipments_contacts USING btree (sandbox_id);


--
-- Name: index_shipments_contacts_on_shipment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_contacts_on_shipment_id ON public.shipments_contacts USING btree (shipment_id);


--
-- Name: index_shipments_documents_on_attachable_type_and_attachable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_documents_on_attachable_type_and_attachable_id ON public.shipments_documents USING btree (attachable_type, attachable_id);


--
-- Name: index_shipments_documents_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_documents_on_sandbox_id ON public.shipments_documents USING btree (sandbox_id);


--
-- Name: index_shipments_invoices_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_invoices_on_sandbox_id ON public.shipments_invoices USING btree (sandbox_id);


--
-- Name: index_shipments_invoices_on_shipment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_invoices_on_shipment_id ON public.shipments_invoices USING btree (shipment_id);


--
-- Name: index_shipments_line_items_on_cargo_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_line_items_on_cargo_id ON public.shipments_line_items USING btree (cargo_id);


--
-- Name: index_shipments_line_items_on_invoice_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_line_items_on_invoice_id ON public.shipments_line_items USING btree (invoice_id);


--
-- Name: index_shipments_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_on_organization_id ON public.shipments USING btree (organization_id);


--
-- Name: index_shipments_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_on_sandbox_id ON public.shipments USING btree (sandbox_id) WHERE (deleted_at IS NULL);


--
-- Name: index_shipments_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_on_tenant_id ON public.shipments USING btree (tenant_id) WHERE (deleted_at IS NULL);


--
-- Name: index_shipments_on_tender_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_on_tender_id ON public.shipments USING btree (tender_id);


--
-- Name: index_shipments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_on_user_id ON public.shipments USING btree (user_id);


--
-- Name: index_shipments_shipment_requests_on_legacy_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_shipment_requests_on_legacy_user_id ON public.shipments_shipment_requests USING btree (legacy_user_id);


--
-- Name: index_shipments_shipment_requests_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_shipment_requests_on_organization_id ON public.shipments_shipment_requests USING btree (organization_id);


--
-- Name: index_shipments_shipment_requests_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_shipment_requests_on_sandbox_id ON public.shipments_shipment_requests USING btree (sandbox_id);


--
-- Name: index_shipments_shipment_requests_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_shipment_requests_on_tenant_id ON public.shipments_shipment_requests USING btree (tenant_id);


--
-- Name: index_shipments_shipment_requests_on_tender_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_shipment_requests_on_tender_id ON public.shipments_shipment_requests USING btree (tender_id);


--
-- Name: index_shipments_shipment_requests_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_shipment_requests_on_user_id ON public.shipments_shipment_requests USING btree (user_id);


--
-- Name: index_shipments_shipments_on_destination_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_shipments_on_destination_id ON public.shipments_shipments USING btree (destination_id);


--
-- Name: index_shipments_shipments_on_legacy_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_shipments_on_legacy_user_id ON public.shipments_shipments USING btree (legacy_user_id);


--
-- Name: index_shipments_shipments_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_shipments_on_organization_id ON public.shipments_shipments USING btree (organization_id);


--
-- Name: index_shipments_shipments_on_origin_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_shipments_on_origin_id ON public.shipments_shipments USING btree (origin_id);


--
-- Name: index_shipments_shipments_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_shipments_on_sandbox_id ON public.shipments_shipments USING btree (sandbox_id);


--
-- Name: index_shipments_shipments_on_shipment_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_shipments_on_shipment_request_id ON public.shipments_shipments USING btree (shipment_request_id);


--
-- Name: index_shipments_shipments_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_shipments_on_tenant_id ON public.shipments_shipments USING btree (tenant_id);


--
-- Name: index_shipments_shipments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_shipments_on_user_id ON public.shipments_shipments USING btree (user_id);


--
-- Name: index_shipments_units_on_cargo_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_units_on_cargo_id ON public.shipments_units USING btree (cargo_id);


--
-- Name: index_shipments_units_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shipments_units_on_sandbox_id ON public.shipments_units USING btree (sandbox_id);


--
-- Name: index_stops_on_hub_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stops_on_hub_id ON public.stops USING btree (hub_id);


--
-- Name: index_stops_on_itinerary_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stops_on_itinerary_id ON public.stops USING btree (itinerary_id);


--
-- Name: index_stops_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stops_on_sandbox_id ON public.stops USING btree (sandbox_id);


--
-- Name: index_tenant_cargo_item_types_on_cargo_item_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_cargo_item_types_on_cargo_item_type_id ON public.tenant_cargo_item_types USING btree (cargo_item_type_id);


--
-- Name: index_tenant_cargo_item_types_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_cargo_item_types_on_organization_id ON public.tenant_cargo_item_types USING btree (organization_id);


--
-- Name: index_tenant_cargo_item_types_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_cargo_item_types_on_sandbox_id ON public.tenant_cargo_item_types USING btree (sandbox_id);


--
-- Name: index_tenant_cargo_item_types_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_cargo_item_types_on_tenant_id ON public.tenant_cargo_item_types USING btree (tenant_id);


--
-- Name: index_tenant_incoterms_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_incoterms_on_organization_id ON public.tenant_incoterms USING btree (organization_id);


--
-- Name: index_tenant_incoterms_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_incoterms_on_tenant_id ON public.tenant_incoterms USING btree (tenant_id);


--
-- Name: index_tenant_routing_connections_on_inbound_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_routing_connections_on_inbound_id ON public.tenant_routing_connections USING btree (inbound_id);


--
-- Name: index_tenant_routing_connections_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_routing_connections_on_organization_id ON public.tenant_routing_connections USING btree (organization_id);


--
-- Name: index_tenant_routing_connections_on_outbound_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_routing_connections_on_outbound_id ON public.tenant_routing_connections USING btree (outbound_id);


--
-- Name: index_tenant_routing_connections_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_routing_connections_on_tenant_id ON public.tenant_routing_connections USING btree (tenant_id);


--
-- Name: index_tenant_routing_routes_on_line_service_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_routing_routes_on_line_service_id ON public.tenant_routing_routes USING btree (line_service_id);


--
-- Name: index_tenant_routing_routes_on_mode_of_transport; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_routing_routes_on_mode_of_transport ON public.tenant_routing_routes USING btree (mode_of_transport);


--
-- Name: index_tenant_routing_routes_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_routing_routes_on_organization_id ON public.tenant_routing_routes USING btree (organization_id);


--
-- Name: index_tenant_routing_routes_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_routing_routes_on_tenant_id ON public.tenant_routing_routes USING btree (tenant_id);


--
-- Name: index_tenant_vehicles_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_vehicles_on_organization_id ON public.tenant_vehicles USING btree (organization_id);


--
-- Name: index_tenant_vehicles_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_vehicles_on_sandbox_id ON public.tenant_vehicles USING btree (sandbox_id);


--
-- Name: index_tenant_vehicles_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenant_vehicles_on_tenant_id ON public.tenant_vehicles USING btree (tenant_id);


--
-- Name: index_tenants_companies_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenants_companies_on_sandbox_id ON public.tenants_companies USING btree (sandbox_id);


--
-- Name: index_tenants_companies_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenants_companies_on_tenant_id ON public.tenants_companies USING btree (tenant_id);


--
-- Name: index_tenants_domains_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenants_domains_on_tenant_id ON public.tenants_domains USING btree (tenant_id);


--
-- Name: index_tenants_groups_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenants_groups_on_sandbox_id ON public.tenants_groups USING btree (sandbox_id);


--
-- Name: index_tenants_groups_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenants_groups_on_tenant_id ON public.tenants_groups USING btree (tenant_id);


--
-- Name: index_tenants_memberships_on_member_type_and_member_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenants_memberships_on_member_type_and_member_id ON public.tenants_memberships USING btree (member_type, member_id);


--
-- Name: index_tenants_memberships_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenants_memberships_on_sandbox_id ON public.tenants_memberships USING btree (sandbox_id);


--
-- Name: index_tenants_saml_metadata_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenants_saml_metadata_on_tenant_id ON public.tenants_saml_metadata USING btree (tenant_id);


--
-- Name: index_tenants_sandboxes_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenants_sandboxes_on_tenant_id ON public.tenants_sandboxes USING btree (tenant_id);


--
-- Name: index_tenants_scopes_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenants_scopes_on_sandbox_id ON public.tenants_scopes USING btree (sandbox_id);


--
-- Name: index_tenants_scopes_on_target_type_and_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenants_scopes_on_target_type_and_target_id ON public.tenants_scopes USING btree (target_type, target_id);


--
-- Name: index_tenants_themes_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenants_themes_on_tenant_id ON public.tenants_themes USING btree (tenant_id);


--
-- Name: index_tenants_users_on_activation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenants_users_on_activation_token ON public.tenants_users USING btree (activation_token);


--
-- Name: index_tenants_users_on_email_and_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tenants_users_on_email_and_tenant_id ON public.tenants_users USING btree (email, tenant_id);


--
-- Name: index_tenants_users_on_last_logout_at_and_last_activity_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenants_users_on_last_logout_at_and_last_activity_at ON public.tenants_users USING btree (last_logout_at, last_activity_at);


--
-- Name: index_tenants_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenants_users_on_reset_password_token ON public.tenants_users USING btree (reset_password_token);


--
-- Name: index_tenants_users_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenants_users_on_sandbox_id ON public.tenants_users USING btree (sandbox_id);


--
-- Name: index_tenants_users_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenants_users_on_tenant_id ON public.tenants_users USING btree (tenant_id);


--
-- Name: index_tenants_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tenants_users_on_unlock_token ON public.tenants_users USING btree (unlock_token);


--
-- Name: index_treasury_exchange_rates_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_treasury_exchange_rates_on_created_at ON public.treasury_exchange_rates USING btree (created_at);


--
-- Name: index_treasury_exchange_rates_on_from; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_treasury_exchange_rates_on_from ON public.treasury_exchange_rates USING btree ("from");


--
-- Name: index_treasury_exchange_rates_on_to; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_treasury_exchange_rates_on_to ON public.treasury_exchange_rates USING btree ("to");


--
-- Name: index_trips_on_closing_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trips_on_closing_date ON public.trips USING btree (closing_date);


--
-- Name: index_trips_on_itinerary_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trips_on_itinerary_id ON public.trips USING btree (itinerary_id);


--
-- Name: index_trips_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trips_on_sandbox_id ON public.trips USING btree (sandbox_id);


--
-- Name: index_trips_on_tenant_vehicle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trips_on_tenant_vehicle_id ON public.trips USING btree (tenant_vehicle_id);


--
-- Name: index_trucking_couriers_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_couriers_on_organization_id ON public.trucking_couriers USING btree (organization_id);


--
-- Name: index_trucking_couriers_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_couriers_on_sandbox_id ON public.trucking_couriers USING btree (sandbox_id);


--
-- Name: index_trucking_couriers_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_couriers_on_tenant_id ON public.trucking_couriers USING btree (tenant_id);


--
-- Name: index_trucking_coverages_on_bounds; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_coverages_on_bounds ON public.trucking_coverages USING gist (bounds);


--
-- Name: index_trucking_coverages_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_coverages_on_sandbox_id ON public.trucking_coverages USING btree (sandbox_id);


--
-- Name: index_trucking_hub_availabilities_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_hub_availabilities_on_deleted_at ON public.trucking_hub_availabilities USING btree (deleted_at);


--
-- Name: index_trucking_hub_availabilities_on_hub_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_hub_availabilities_on_hub_id ON public.trucking_hub_availabilities USING btree (hub_id);


--
-- Name: index_trucking_hub_availabilities_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_hub_availabilities_on_sandbox_id ON public.trucking_hub_availabilities USING btree (sandbox_id);


--
-- Name: index_trucking_hub_availabilities_on_type_availability_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_hub_availabilities_on_type_availability_id ON public.trucking_hub_availabilities USING btree (type_availability_id);


--
-- Name: index_trucking_locations_on_city_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_locations_on_city_name ON public.trucking_locations USING btree (city_name);


--
-- Name: index_trucking_locations_on_country_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_locations_on_country_code ON public.trucking_locations USING btree (country_code);


--
-- Name: index_trucking_locations_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_locations_on_country_id ON public.trucking_locations USING btree (country_id);


--
-- Name: index_trucking_locations_on_data; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_locations_on_data ON public.trucking_locations USING btree (data);


--
-- Name: index_trucking_locations_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_locations_on_deleted_at ON public.trucking_locations USING btree (deleted_at);


--
-- Name: index_trucking_locations_on_distance; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_locations_on_distance ON public.trucking_locations USING btree (distance);


--
-- Name: index_trucking_locations_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_locations_on_location_id ON public.trucking_locations USING btree (location_id);


--
-- Name: index_trucking_locations_on_query; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_locations_on_query ON public.trucking_locations USING btree (query);


--
-- Name: index_trucking_locations_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_locations_on_sandbox_id ON public.trucking_locations USING btree (sandbox_id);


--
-- Name: index_trucking_locations_on_zipcode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_locations_on_zipcode ON public.trucking_locations USING btree (zipcode);


--
-- Name: index_trucking_rates_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_rates_on_organization_id ON public.trucking_rates USING btree (organization_id);


--
-- Name: index_trucking_rates_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_rates_on_tenant_id ON public.trucking_rates USING btree (tenant_id);


--
-- Name: index_trucking_rates_on_trucking_scope_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_rates_on_trucking_scope_id ON public.trucking_rates USING btree (scope_id);


--
-- Name: index_trucking_type_availabilities_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_type_availabilities_on_country_id ON public.trucking_type_availabilities USING btree (country_id);


--
-- Name: index_trucking_type_availabilities_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_type_availabilities_on_deleted_at ON public.trucking_type_availabilities USING btree (deleted_at);


--
-- Name: index_trucking_type_availabilities_on_load_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_type_availabilities_on_load_type ON public.trucking_type_availabilities USING btree (load_type);


--
-- Name: index_trucking_type_availabilities_on_query_method; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_type_availabilities_on_query_method ON public.trucking_type_availabilities USING btree (query_method);


--
-- Name: index_trucking_type_availabilities_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_type_availabilities_on_sandbox_id ON public.trucking_type_availabilities USING btree (sandbox_id);


--
-- Name: index_trucking_type_availabilities_on_truck_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucking_type_availabilities_on_truck_type ON public.trucking_type_availabilities USING btree (truck_type);


--
-- Name: index_truckings_on_cargo_class; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_truckings_on_cargo_class ON public.trucking_truckings USING btree (cargo_class);


--
-- Name: index_truckings_on_carriage; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_truckings_on_carriage ON public.trucking_truckings USING btree (carriage);


--
-- Name: index_truckings_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_truckings_on_deleted_at ON public.trucking_truckings USING btree (deleted_at);


--
-- Name: index_truckings_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_truckings_on_group_id ON public.trucking_truckings USING btree (group_id);


--
-- Name: index_truckings_on_hub_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_truckings_on_hub_id ON public.trucking_truckings USING btree (hub_id);


--
-- Name: index_truckings_on_load_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_truckings_on_load_type ON public.trucking_truckings USING btree (load_type);


--
-- Name: index_truckings_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_truckings_on_location_id ON public.trucking_truckings USING btree (location_id);


--
-- Name: index_truckings_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_truckings_on_organization_id ON public.trucking_truckings USING btree (organization_id);


--
-- Name: index_truckings_on_tenant_vehicle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_truckings_on_tenant_vehicle_id ON public.trucking_truckings USING btree (tenant_vehicle_id);


--
-- Name: index_truckings_on_validity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_truckings_on_validity ON public.trucking_truckings USING gist (validity);


--
-- Name: index_user_addresses_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_addresses_on_deleted_at ON public.user_addresses USING btree (deleted_at);


--
-- Name: index_user_addresses_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_addresses_on_user_id ON public.user_addresses USING btree (user_id);


--
-- Name: index_user_managers_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_managers_on_user_id ON public.user_managers USING btree (user_id);


--
-- Name: index_users_admins_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_admins_on_email ON public.users_admins USING btree (email);


--
-- Name: index_users_authentications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_authentications_on_user_id ON public.users_authentications USING btree (user_id);


--
-- Name: index_users_client_profiles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_client_profiles_on_user_id ON public.users_client_profiles USING btree (user_id);


--
-- Name: index_users_client_settings_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_client_settings_on_user_id ON public.users_client_settings USING btree (user_id);


--
-- Name: index_users_clients_on_activation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_clients_on_activation_token ON public.users_clients USING btree (activation_token) WHERE (deleted_at IS NULL);


--
-- Name: index_users_clients_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_clients_on_email ON public.users_clients USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: index_users_clients_on_email_and_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_clients_on_email_and_organization_id ON public.users_clients USING btree (email, organization_id);


--
-- Name: index_users_clients_on_magic_login_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_clients_on_magic_login_token ON public.users_clients USING btree (magic_login_token) WHERE (deleted_at IS NULL);


--
-- Name: index_users_clients_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_clients_on_organization_id ON public.users_clients USING btree (organization_id);


--
-- Name: index_users_clients_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_clients_on_reset_password_token ON public.users_clients USING btree (reset_password_token) WHERE (deleted_at IS NULL);


--
-- Name: index_users_clients_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_clients_on_unlock_token ON public.users_clients USING btree (unlock_token) WHERE (deleted_at IS NULL);


--
-- Name: index_users_memberships_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_memberships_on_organization_id ON public.users_memberships USING btree (organization_id);


--
-- Name: index_users_memberships_on_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_memberships_on_role ON public.users_memberships USING btree (role);


--
-- Name: index_users_memberships_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_memberships_on_user_id ON public.users_memberships USING btree (user_id);


--
-- Name: index_users_memberships_on_user_id_and_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_memberships_on_user_id_and_organization_id ON public.users_memberships USING btree (user_id, organization_id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_deleted_at ON public.users USING btree (deleted_at);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_organization_id ON public.users USING btree (organization_id);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_role_id ON public.users USING btree (role_id);


--
-- Name: index_users_on_sandbox_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_sandbox_id ON public.users USING btree (sandbox_id);


--
-- Name: index_users_on_tenant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_tenant_id ON public.users USING btree (tenant_id);


--
-- Name: index_users_on_uid_and_provider; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_uid_and_provider ON public.users USING btree (uid, provider);


--
-- Name: index_users_profiles_on_legacy_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_profiles_on_legacy_user_id ON public.users_profiles USING btree (legacy_user_id);


--
-- Name: index_users_profiles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_profiles_on_user_id ON public.users_profiles USING btree (user_id);


--
-- Name: index_users_settings_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_settings_on_deleted_at ON public.users_settings USING btree (deleted_at);


--
-- Name: index_users_settings_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_settings_on_user_id ON public.users_settings USING btree (user_id);


--
-- Name: index_users_users_on_activation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_users_on_activation_token ON public.users_users USING btree (activation_token) WHERE (deleted_at IS NULL);


--
-- Name: index_users_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_users_on_email ON public.users_users USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: index_users_users_on_email_and_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_users_on_email_and_organization_id ON public.users_users USING btree (email, organization_id);


--
-- Name: index_users_users_on_email_and_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_users_on_email_and_type ON public.users_users USING btree (email, type) WHERE (organization_id IS NULL);


--
-- Name: index_users_users_on_magic_login_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_users_on_magic_login_token ON public.users_users USING btree (magic_login_token) WHERE (deleted_at IS NULL);


--
-- Name: index_users_users_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_users_on_organization_id ON public.users_users USING btree (organization_id);


--
-- Name: index_users_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_users_on_reset_password_token ON public.users_users USING btree (reset_password_token) WHERE (deleted_at IS NULL);


--
-- Name: index_users_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_users_on_unlock_token ON public.users_users USING btree (unlock_token) WHERE (deleted_at IS NULL);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_item_type_and_item_id ON public.versions USING btree (item_type, item_id);


--
-- Name: ledger_delta_target_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ledger_delta_target_index ON public.ledger_delta USING btree (target_type, target_id);


--
-- Name: ledger_rate_target_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ledger_rate_target_index ON public.ledger_rates USING btree (target_type, target_id);


--
-- Name: line_service_unique_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX line_service_unique_index ON public.routing_line_services USING btree (carrier_id, name);


--
-- Name: locations_names_to_tsvector_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locations_names_to_tsvector_idx1 ON public.locations_names USING gin (to_tsvector('english'::regconfig, (country)::text));


--
-- Name: locations_names_to_tsvector_idx10; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locations_names_to_tsvector_idx10 ON public.locations_names USING gin (to_tsvector('english'::regconfig, (city)::text));


--
-- Name: locations_names_to_tsvector_idx3; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locations_names_to_tsvector_idx3 ON public.locations_names USING gin (to_tsvector('english'::regconfig, (language)::text));


--
-- Name: locations_names_to_tsvector_idx4; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locations_names_to_tsvector_idx4 ON public.locations_names USING gin (to_tsvector('english'::regconfig, (osm_id)::text));


--
-- Name: locations_names_to_tsvector_idx5; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locations_names_to_tsvector_idx5 ON public.locations_names USING gin (to_tsvector('english'::regconfig, (country_code)::text));


--
-- Name: locations_names_to_tsvector_idx6; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locations_names_to_tsvector_idx6 ON public.locations_names USING gin (to_tsvector('english'::regconfig, (display_name)::text));


--
-- Name: locations_names_to_tsvector_idx7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locations_names_to_tsvector_idx7 ON public.locations_names USING gin (to_tsvector('english'::regconfig, (name)::text));


--
-- Name: locations_names_to_tsvector_idx8; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locations_names_to_tsvector_idx8 ON public.locations_names USING gin (to_tsvector('english'::regconfig, (alternative_names)::text));


--
-- Name: locations_names_to_tsvector_idx9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX locations_names_to_tsvector_idx9 ON public.locations_names USING gin (to_tsvector('english'::regconfig, (postal_code)::text));


--
-- Name: provider_uid_on_users_authentications; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX provider_uid_on_users_authentications ON public.users_authentications USING btree (provider, uid);


--
-- Name: route_line_service_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX route_line_service_index ON public.routing_route_line_services USING btree (route_id, line_service_id);


--
-- Name: routing_carriers_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX routing_carriers_index ON public.routing_carriers USING btree (name, code, abbreviated_name);


--
-- Name: routing_routes_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX routing_routes_index ON public.routing_routes USING btree (origin_id, destination_id, origin_terminal_id, destination_terminal_id, mode_of_transport);


--
-- Name: trucking_hub_avilabilities_unique_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX trucking_hub_avilabilities_unique_index ON public.trucking_hub_availabilities USING btree (hub_id, type_availability_id) WHERE (deleted_at IS NULL);


--
-- Name: trucking_type_availabilities_unique_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX trucking_type_availabilities_unique_index ON public.trucking_type_availabilities USING btree (carriage, load_type, country_id, truck_type, query_method) WHERE (deleted_at IS NULL);


--
-- Name: uniq_index_1; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_index_1 ON public.locations_names USING btree (language, osm_id, street, country, country_code, display_name, name, postal_code);


--
-- Name: users_clients_activity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_clients_activity ON public.users_clients USING btree (last_logout_at, last_activity_at) WHERE (deleted_at IS NULL);


--
-- Name: users_users_activity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_users_activity ON public.users_users USING btree (last_logout_at, last_activity_at) WHERE (deleted_at IS NULL);


--
-- Name: visibility_connection_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX visibility_connection_index ON public.tenant_routing_visibilities USING btree (connection_id);


--
-- Name: visibility_target_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX visibility_target_index ON public.tenant_routing_visibilities USING btree (target_type, target_id);


--
-- Name: pricings_metadata fk_rails_01818578ab; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pricings_metadata
    ADD CONSTRAINT fk_rails_01818578ab FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: shipments_shipment_requests fk_rails_03532ed857; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments_shipment_requests
    ADD CONSTRAINT fk_rails_03532ed857 FOREIGN KEY (sandbox_id) REFERENCES public.tenants_sandboxes(id);


--
-- Name: users_memberships fk_rails_0becb5aad6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_memberships
    ADD CONSTRAINT fk_rails_0becb5aad6 FOREIGN KEY (user_id) REFERENCES public.users_users(id);


--
-- Name: users_client_profiles fk_rails_10b9398b35; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_client_profiles
    ADD CONSTRAINT fk_rails_10b9398b35 FOREIGN KEY (user_id) REFERENCES public.users_clients(id) ON DELETE CASCADE;


--
-- Name: journey_offer_line_item_sets fk_rails_13ac752815; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_offer_line_item_sets
    ADD CONSTRAINT fk_rails_13ac752815 FOREIGN KEY (line_item_set_id) REFERENCES public.journey_line_item_sets(id) ON DELETE CASCADE;


--
-- Name: agencies fk_rails_14ed559d97; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agencies
    ADD CONSTRAINT fk_rails_14ed559d97 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: legacy_transit_times fk_rails_1571683159; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_transit_times
    ADD CONSTRAINT fk_rails_1571683159 FOREIGN KEY (itinerary_id) REFERENCES public.itineraries(id) ON DELETE CASCADE;


--
-- Name: journey_line_items fk_rails_195193f869; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_line_items
    ADD CONSTRAINT fk_rails_195193f869 FOREIGN KEY (route_section_id) REFERENCES public.journey_route_sections(id) ON DELETE CASCADE;


--
-- Name: rms_data_books fk_rails_1bf082076e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rms_data_books
    ADD CONSTRAINT fk_rails_1bf082076e FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: rates_cargos fk_rails_1bf3ec64d6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rates_cargos
    ADD CONSTRAINT fk_rails_1bf3ec64d6 FOREIGN KEY (section_id) REFERENCES public.rates_sections(id);


--
-- Name: rates_sections fk_rails_1d28b148e0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rates_sections
    ADD CONSTRAINT fk_rails_1d28b148e0 FOREIGN KEY (terminal_id) REFERENCES public.routing_terminals(id);


--
-- Name: notifications_subscriptions fk_rails_1d3dd3e417; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications_subscriptions
    ADD CONSTRAINT fk_rails_1d3dd3e417 FOREIGN KEY (user_id) REFERENCES public.users_users(id);


--
-- Name: tenant_cargo_item_types fk_rails_1ee8e33ff7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_cargo_item_types
    ADD CONSTRAINT fk_rails_1ee8e33ff7 FOREIGN KEY (cargo_item_type_id) REFERENCES public.cargo_item_types(id);


--
-- Name: rates_sections fk_rails_1eea053bc9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rates_sections
    ADD CONSTRAINT fk_rails_1eea053bc9 FOREIGN KEY (carrier_id) REFERENCES public.carriers(id);


--
-- Name: trucking_couriers fk_rails_23e353cdb4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trucking_couriers
    ADD CONSTRAINT fk_rails_23e353cdb4 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: charge_breakdowns fk_rails_271edacff3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.charge_breakdowns
    ADD CONSTRAINT fk_rails_271edacff3 FOREIGN KEY (delivery_tenant_vehicle_id) REFERENCES public.tenant_vehicles(id);


--
-- Name: charge_categories fk_rails_27256298fb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.charge_categories
    ADD CONSTRAINT fk_rails_27256298fb FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: shipments_contacts fk_rails_2812f62eec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments_contacts
    ADD CONSTRAINT fk_rails_2812f62eec FOREIGN KEY (sandbox_id) REFERENCES public.tenants_sandboxes(id);


--
-- Name: organizations_themes fk_rails_29dc7fb43d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations_themes
    ADD CONSTRAINT fk_rails_29dc7fb43d FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: shipments_shipment_requests fk_rails_2d66d5e56e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments_shipment_requests
    ADD CONSTRAINT fk_rails_2d66d5e56e FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: journey_errors fk_rails_2d9661ddf7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_errors
    ADD CONSTRAINT fk_rails_2d9661ddf7 FOREIGN KEY (cargo_unit_id) REFERENCES public.journey_cargo_units(id) ON DELETE CASCADE;


--
-- Name: organizations_integration_tokens fk_rails_2e029f7c1e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations_integration_tokens
    ADD CONSTRAINT fk_rails_2e029f7c1e FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: companies_companies fk_rails_2fb4c39109; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies_companies
    ADD CONSTRAINT fk_rails_2fb4c39109 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: pricings_details fk_rails_37ead9b677; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pricings_details
    ADD CONSTRAINT fk_rails_37ead9b677 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: journey_shipments fk_rails_4028c4cb14; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_shipments
    ADD CONSTRAINT fk_rails_4028c4cb14 FOREIGN KEY (shipment_request_id) REFERENCES public.journey_shipment_requests(id) ON DELETE CASCADE;


--
-- Name: cargo_cargos fk_rails_44a64b87b9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cargo_cargos
    ADD CONSTRAINT fk_rails_44a64b87b9 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: journey_offer_results fk_rails_455c8d50e7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_offer_results
    ADD CONSTRAINT fk_rails_455c8d50e7 FOREIGN KEY (offer_id) REFERENCES public.journey_offers(id) ON DELETE CASCADE;


--
-- Name: shipments_shipment_request_contacts fk_rails_45a83615f3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments_shipment_request_contacts
    ADD CONSTRAINT fk_rails_45a83615f3 FOREIGN KEY (contact_id) REFERENCES public.address_book_contacts(id);


--
-- Name: shipments_shipments fk_rails_45b1f0b520; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments_shipments
    ADD CONSTRAINT fk_rails_45b1f0b520 FOREIGN KEY (destination_id) REFERENCES public.routing_terminals(id);


--
-- Name: journey_queries fk_rails_46beaf6bf6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_queries
    ADD CONSTRAINT fk_rails_46beaf6bf6 FOREIGN KEY (company_id) REFERENCES public.companies_companies(id) ON DELETE CASCADE;


--
-- Name: shipments fk_rails_4acecd6f16; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT fk_rails_4acecd6f16 FOREIGN KEY (destination_nexus_id) REFERENCES public.nexuses(id) ON DELETE SET NULL;


--
-- Name: groups_memberships fk_rails_4ee4e8e534; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups_memberships
    ADD CONSTRAINT fk_rails_4ee4e8e534 FOREIGN KEY (group_id) REFERENCES public.groups_groups(id);


--
-- Name: tenant_routing_routes fk_rails_505fa01ce8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_routing_routes
    ADD CONSTRAINT fk_rails_505fa01ce8 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: tenant_vehicles fk_rails_51f9ff2e10; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_vehicles
    ADD CONSTRAINT fk_rails_51f9ff2e10 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: journey_shipment_requests fk_rails_58ba0dc412; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_shipment_requests
    ADD CONSTRAINT fk_rails_58ba0dc412 FOREIGN KEY (company_id) REFERENCES public.companies_companies(id) ON DELETE CASCADE;


--
-- Name: itineraries fk_rails_59620239e4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.itineraries
    ADD CONSTRAINT fk_rails_59620239e4 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: shipments fk_rails_5fb975ea14; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT fk_rails_5fb975ea14 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: journey_line_item_sets fk_rails_6186942462; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_line_item_sets
    ADD CONSTRAINT fk_rails_6186942462 FOREIGN KEY (result_id) REFERENCES public.journey_results(id) ON DELETE CASCADE;


--
-- Name: journey_result_sets fk_rails_6387719f4d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_result_sets
    ADD CONSTRAINT fk_rails_6387719f4d FOREIGN KEY (query_id) REFERENCES public.journey_queries(id) ON DELETE CASCADE;


--
-- Name: users fk_rails_642f17018b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_642f17018b FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: max_dimensions_bundles fk_rails_6493354d7b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.max_dimensions_bundles
    ADD CONSTRAINT fk_rails_6493354d7b FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: organizations_saml_metadata fk_rails_64f8fb6faa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations_saml_metadata
    ADD CONSTRAINT fk_rails_64f8fb6faa FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: journey_shipment_requests fk_rails_6686626367; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_shipment_requests
    ADD CONSTRAINT fk_rails_6686626367 FOREIGN KEY (result_id) REFERENCES public.journey_results(id) ON DELETE CASCADE;


--
-- Name: pricings_fees fk_rails_673fbf0e45; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pricings_fees
    ADD CONSTRAINT fk_rails_673fbf0e45 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: quotations_tenders fk_rails_677ff1e7ae; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotations_tenders
    ADD CONSTRAINT fk_rails_677ff1e7ae FOREIGN KEY (quotation_id) REFERENCES public.quotations_quotations(id);


--
-- Name: journey_shipments fk_rails_67ca424550; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_shipments
    ADD CONSTRAINT fk_rails_67ca424550 FOREIGN KEY (creator_id) REFERENCES public.users_users(id) ON DELETE CASCADE;


--
-- Name: quotations_quotations fk_rails_6c43d2e853; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotations_quotations
    ADD CONSTRAINT fk_rails_6c43d2e853 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: pricings_pricings fk_rails_6cebea4109; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pricings_pricings
    ADD CONSTRAINT fk_rails_6cebea4109 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: journey_offer_line_item_sets fk_rails_726fd2f78d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_offer_line_item_sets
    ADD CONSTRAINT fk_rails_726fd2f78d FOREIGN KEY (offer_id) REFERENCES public.journey_offers(id) ON DELETE CASCADE;


--
-- Name: itineraries fk_rails_73157e6dfb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.itineraries
    ADD CONSTRAINT fk_rails_73157e6dfb FOREIGN KEY (origin_hub_id) REFERENCES public.hubs(id) ON DELETE CASCADE;


--
-- Name: oauth_access_tokens fk_rails_732cb83ab7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT fk_rails_732cb83ab7 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- Name: itineraries fk_rails_75475c742e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.itineraries
    ADD CONSTRAINT fk_rails_75475c742e FOREIGN KEY (destination_hub_id) REFERENCES public.hubs(id) ON DELETE CASCADE;


--
-- Name: trucking_rates fk_rails_75f3ea54ff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trucking_rates
    ADD CONSTRAINT fk_rails_75f3ea54ff FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: shipments_invoices fk_rails_76b3516160; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments_invoices
    ADD CONSTRAINT fk_rails_76b3516160 FOREIGN KEY (sandbox_id) REFERENCES public.tenants_sandboxes(id);


--
-- Name: cargo_units fk_rails_781259d9f8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cargo_units
    ADD CONSTRAINT fk_rails_781259d9f8 FOREIGN KEY (cargo_id) REFERENCES public.cargo_cargos(id);


--
-- Name: ledger_rates fk_rails_79037cba6b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ledger_rates
    ADD CONSTRAINT fk_rails_79037cba6b FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: shipments_shipments fk_rails_79383595c2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments_shipments
    ADD CONSTRAINT fk_rails_79383595c2 FOREIGN KEY (origin_id) REFERENCES public.routing_terminals(id);


--
-- Name: journey_documents fk_rails_7afcf001ae; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_documents
    ADD CONSTRAINT fk_rails_7afcf001ae FOREIGN KEY (query_id) REFERENCES public.journey_queries(id) ON DELETE CASCADE;


--
-- Name: users_profiles fk_rails_7c1bb95722; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_profiles
    ADD CONSTRAINT fk_rails_7c1bb95722 FOREIGN KEY (user_id) REFERENCES public.users_users(id);


--
-- Name: companies_memberships fk_rails_7ce0bdc528; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies_memberships
    ADD CONSTRAINT fk_rails_7ce0bdc528 FOREIGN KEY (company_id) REFERENCES public.companies_companies(id);


--
-- Name: shipments_shipments fk_rails_7d4f331dff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments_shipments
    ADD CONSTRAINT fk_rails_7d4f331dff FOREIGN KEY (sandbox_id) REFERENCES public.tenants_sandboxes(id);


--
-- Name: journey_line_items fk_rails_7ecd925037; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_line_items
    ADD CONSTRAINT fk_rails_7ecd925037 FOREIGN KEY (route_point_id) REFERENCES public.journey_route_points(id) ON DELETE CASCADE;


--
-- Name: quotations_tenders fk_rails_7fa9339f82; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotations_tenders
    ADD CONSTRAINT fk_rails_7fa9339f82 FOREIGN KEY (pickup_tenant_vehicle_id) REFERENCES public.tenant_vehicles(id);


--
-- Name: legacy_transit_times fk_rails_83ef2a5f36; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_transit_times
    ADD CONSTRAINT fk_rails_83ef2a5f36 FOREIGN KEY (tenant_vehicle_id) REFERENCES public.tenant_vehicles(id) ON DELETE CASCADE;


--
-- Name: legacy_contents fk_rails_8483f8b55c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_contents
    ADD CONSTRAINT fk_rails_8483f8b55c FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: users_memberships fk_rails_84f4e71154; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_memberships
    ADD CONSTRAINT fk_rails_84f4e71154 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: rates_discounts fk_rails_852c55ba6b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rates_discounts
    ADD CONSTRAINT fk_rails_852c55ba6b FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: shipments fk_rails_85ae2094c3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT fk_rails_85ae2094c3 FOREIGN KEY (destination_hub_id) REFERENCES public.hubs(id) ON DELETE SET NULL;


--
-- Name: hubs fk_rails_87a8d9c154; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hubs
    ADD CONSTRAINT fk_rails_87a8d9c154 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: shipments_shipment_requests fk_rails_88d801b1b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments_shipment_requests
    ADD CONSTRAINT fk_rails_88d801b1b8 FOREIGN KEY (tender_id) REFERENCES public.quotations_tenders(id);


--
-- Name: rates_sections fk_rails_8bbc8da44e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rates_sections
    ADD CONSTRAINT fk_rails_8bbc8da44e FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: journey_cargo_units fk_rails_8be1f1fbb6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_cargo_units
    ADD CONSTRAINT fk_rails_8be1f1fbb6 FOREIGN KEY (query_id) REFERENCES public.journey_queries(id) ON DELETE CASCADE;


--
-- Name: organizations_domains fk_rails_8c6c49b797; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations_domains
    ADD CONSTRAINT fk_rails_8c6c49b797 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: stops fk_rails_8f2fbeb88c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stops
    ADD CONSTRAINT fk_rails_8f2fbeb88c FOREIGN KEY (itinerary_id) REFERENCES public.itineraries(id);


--
-- Name: rms_data_sheets fk_rails_8f4c6951df; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rms_data_sheets
    ADD CONSTRAINT fk_rails_8f4c6951df FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: shipments_units fk_rails_93955cf33b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments_units
    ADD CONSTRAINT fk_rails_93955cf33b FOREIGN KEY (sandbox_id) REFERENCES public.tenants_sandboxes(id);


--
-- Name: shipments fk_rails_93f56a6bd4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT fk_rails_93f56a6bd4 FOREIGN KEY (origin_nexus_id) REFERENCES public.nexuses(id) ON DELETE SET NULL;


--
-- Name: notifications_subscriptions fk_rails_9679ae7ef8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications_subscriptions
    ADD CONSTRAINT fk_rails_9679ae7ef8 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: journey_contacts fk_rails_96dca9d5bc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_contacts
    ADD CONSTRAINT fk_rails_96dca9d5bc FOREIGN KEY (shipment_request_id) REFERENCES public.journey_shipment_requests(id) ON DELETE CASCADE;


--
-- Name: rates_fees fk_rails_9867297d6a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rates_fees
    ADD CONSTRAINT fk_rails_9867297d6a FOREIGN KEY (cargo_id) REFERENCES public.rates_cargos(id);


--
-- Name: nexuses fk_rails_98e7917902; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nexuses
    ADD CONSTRAINT fk_rails_98e7917902 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: journey_offer_results fk_rails_998f64d3aa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_offer_results
    ADD CONSTRAINT fk_rails_998f64d3aa FOREIGN KEY (result_id) REFERENCES public.journey_results(id) ON DELETE CASCADE;


--
-- Name: addons fk_rails_99b6240dc9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addons
    ADD CONSTRAINT fk_rails_99b6240dc9 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: cargo_cargos fk_rails_9a376fbecc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cargo_cargos
    ADD CONSTRAINT fk_rails_9a376fbecc FOREIGN KEY (quotation_id) REFERENCES public.quotations_quotations(id);


--
-- Name: journey_line_items fk_rails_9c5fbc06ce; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_line_items
    ADD CONSTRAINT fk_rails_9c5fbc06ce FOREIGN KEY (line_item_set_id) REFERENCES public.journey_line_item_sets(id) ON DELETE CASCADE;


--
-- Name: map_data fk_rails_9d184ecaed; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.map_data
    ADD CONSTRAINT fk_rails_9d184ecaed FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: remarks fk_rails_a7725ab891; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.remarks
    ADD CONSTRAINT fk_rails_a7725ab891 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: local_charges fk_rails_a9ea4791a4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_charges
    ADD CONSTRAINT fk_rails_a9ea4791a4 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: quotations_tenders fk_rails_aaaa6bc7f4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quotations_tenders
    ADD CONSTRAINT fk_rails_aaaa6bc7f4 FOREIGN KEY (delivery_tenant_vehicle_id) REFERENCES public.tenant_vehicles(id);


--
-- Name: rates_margins fk_rails_aad768542b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rates_margins
    ADD CONSTRAINT fk_rails_aad768542b FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: cms_data_widgets fk_rails_ab06deb360; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cms_data_widgets
    ADD CONSTRAINT fk_rails_ab06deb360 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: currencies fk_rails_ac4f244b6d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currencies
    ADD CONSTRAINT fk_rails_ac4f244b6d FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: shipments_cargos fk_rails_af3cb50c1d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments_cargos
    ADD CONSTRAINT fk_rails_af3cb50c1d FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: journey_route_sections fk_rails_b0e689ba29; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_route_sections
    ADD CONSTRAINT fk_rails_b0e689ba29 FOREIGN KEY (from_id) REFERENCES public.journey_route_points(id) ON DELETE CASCADE;


--
-- Name: shipments_documents fk_rails_b1608cd908; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments_documents
    ADD CONSTRAINT fk_rails_b1608cd908 FOREIGN KEY (sandbox_id) REFERENCES public.tenants_sandboxes(id);


--
-- Name: shipments_shipments fk_rails_b1cdb6e99b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments_shipments
    ADD CONSTRAINT fk_rails_b1cdb6e99b FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: oauth_access_grants fk_rails_b4b53e07b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT fk_rails_b4b53e07b8 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- Name: tenant_incoterms fk_rails_b6614e31bc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_incoterms
    ADD CONSTRAINT fk_rails_b6614e31bc FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: journey_route_sections fk_rails_b9160f28bd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_route_sections
    ADD CONSTRAINT fk_rails_b9160f28bd FOREIGN KEY (result_id) REFERENCES public.journey_results(id) ON DELETE CASCADE;


--
-- Name: rates_sections fk_rails_bbae927883; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rates_sections
    ADD CONSTRAINT fk_rails_bbae927883 FOREIGN KEY (location_id) REFERENCES public.routing_locations(id);


--
-- Name: journey_line_item_cargo_units fk_rails_bc005e370c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_line_item_cargo_units
    ADD CONSTRAINT fk_rails_bc005e370c FOREIGN KEY (line_item_id) REFERENCES public.journey_line_items(id) ON DELETE CASCADE;


--
-- Name: journey_route_sections fk_rails_bea87acd56; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_route_sections
    ADD CONSTRAINT fk_rails_bea87acd56 FOREIGN KEY (to_id) REFERENCES public.journey_route_points(id) ON DELETE CASCADE;


--
-- Name: users_client_settings fk_rails_c191a9e642; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_client_settings
    ADD CONSTRAINT fk_rails_c191a9e642 FOREIGN KEY (user_id) REFERENCES public.users_clients(id) ON DELETE CASCADE;


--
-- Name: rms_data_cells fk_rails_c5edb42f5f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rms_data_cells
    ADD CONSTRAINT fk_rails_c5edb42f5f FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: journey_commodity_infos fk_rails_c6e003215c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_commodity_infos
    ADD CONSTRAINT fk_rails_c6e003215c FOREIGN KEY (cargo_unit_id) REFERENCES public.journey_cargo_units(id) ON DELETE CASCADE;


--
-- Name: journey_offers fk_rails_c7cf09400f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_offers
    ADD CONSTRAINT fk_rails_c7cf09400f FOREIGN KEY (query_id) REFERENCES public.journey_queries(id);


--
-- Name: tenant_routing_connections fk_rails_c8925af1c0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_routing_connections
    ADD CONSTRAINT fk_rails_c8925af1c0 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: trucking_truckings fk_rails_c9b2b3a658; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trucking_truckings
    ADD CONSTRAINT fk_rails_c9b2b3a658 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: shipments_cargos fk_rails_cc1f5a011e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments_cargos
    ADD CONSTRAINT fk_rails_cc1f5a011e FOREIGN KEY (sandbox_id) REFERENCES public.tenants_sandboxes(id);


--
-- Name: journey_results fk_rails_cf8579713a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_results
    ADD CONSTRAINT fk_rails_cf8579713a FOREIGN KEY (result_set_id) REFERENCES public.journey_result_sets(id) ON DELETE CASCADE;


--
-- Name: tenant_cargo_item_types fk_rails_d26d6b4d72; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_cargo_item_types
    ADD CONSTRAINT fk_rails_d26d6b4d72 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: address_book_contacts fk_rails_d423ff13fc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.address_book_contacts
    ADD CONSTRAINT fk_rails_d423ff13fc FOREIGN KEY (sandbox_id) REFERENCES public.tenants_sandboxes(id);


--
-- Name: legacy_files fk_rails_d4b5634e71; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_files
    ADD CONSTRAINT fk_rails_d4b5634e71 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: shipments fk_rails_d52aa5da4a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT fk_rails_d52aa5da4a FOREIGN KEY (origin_hub_id) REFERENCES public.hubs(id) ON DELETE SET NULL;


--
-- Name: users fk_rails_d7b9ff90af; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_d7b9ff90af FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: journey_queries fk_rails_dad02b35f7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_queries
    ADD CONSTRAINT fk_rails_dad02b35f7 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id) ON DELETE CASCADE;


--
-- Name: customs_fees fk_rails_e4008c2f77; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customs_fees
    ADD CONSTRAINT fk_rails_e4008c2f77 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: pricings_margins fk_rails_e63b427b7b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pricings_margins
    ADD CONSTRAINT fk_rails_e63b427b7b FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: journey_errors fk_rails_e919efdd24; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_errors
    ADD CONSTRAINT fk_rails_e919efdd24 FOREIGN KEY (result_set_id) REFERENCES public.journey_result_sets(id) ON DELETE CASCADE;


--
-- Name: companies_companies fk_rails_ea445f05dc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies_companies
    ADD CONSTRAINT fk_rails_ea445f05dc FOREIGN KEY (address_id) REFERENCES public.addresses(id);


--
-- Name: users_settings fk_rails_ea528144ba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_settings
    ADD CONSTRAINT fk_rails_ea528144ba FOREIGN KEY (user_id) REFERENCES public.users_users(id);


--
-- Name: groups_groups fk_rails_ebbca73e82; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups_groups
    ADD CONSTRAINT fk_rails_ebbca73e82 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: notes fk_rails_eef74d5cc8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT fk_rails_eef74d5cc8 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: cargo_units fk_rails_f212c5c9a8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cargo_units
    ADD CONSTRAINT fk_rails_f212c5c9a8 FOREIGN KEY (organization_id) REFERENCES public.organizations_organizations(id);


--
-- Name: journey_line_item_sets fk_rails_f577c81f85; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_line_item_sets
    ADD CONSTRAINT fk_rails_f577c81f85 FOREIGN KEY (shipment_request_id) REFERENCES public.journey_shipment_requests(id) ON DELETE CASCADE;


--
-- Name: charge_breakdowns fk_rails_fae196182a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.charge_breakdowns
    ADD CONSTRAINT fk_rails_fae196182a FOREIGN KEY (pickup_tenant_vehicle_id) REFERENCES public.tenant_vehicles(id);


--
-- Name: journey_line_item_cargo_units fk_rails_fbc95294b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_line_item_cargo_units
    ADD CONSTRAINT fk_rails_fbc95294b8 FOREIGN KEY (cargo_unit_id) REFERENCES public.journey_cargo_units(id) ON DELETE CASCADE;


--
-- Name: charge_breakdowns fk_rails_fe05304bf4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.charge_breakdowns
    ADD CONSTRAINT fk_rails_fe05304bf4 FOREIGN KEY (freight_tenant_vehicle_id) REFERENCES public.tenant_vehicles(id);


--
-- Name: journey_documents fk_rails_ff54d07ec6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journey_documents
    ADD CONSTRAINT fk_rails_ff54d07ec6 FOREIGN KEY (shipment_request_id) REFERENCES public.journey_shipment_requests(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO public;

INSERT INTO "schema_migrations" (version) VALUES
('20171109083404'),
('20171109083421'),
('20171109083427'),
('20171109083435'),
('20171109083443'),
('20171109083456'),
('20171109083504'),
('20171109083514'),
('20171109083541'),
('20171109083631'),
('20171109083809'),
('20171109083838'),
('20171109083844'),
('20171109084109'),
('20171109093035'),
('20171109093443'),
('20171120112859'),
('20171120113058'),
('20171128095139'),
('20171129100133'),
('20171201142706'),
('20171201143205'),
('20171207171641'),
('20171208133839'),
('20171208133853'),
('20171208134130'),
('20171208135516'),
('20171211102844'),
('20171211180745'),
('20171213151916'),
('20171218161528'),
('20171220153514'),
('20180102113747'),
('20180102143205'),
('20180102173637'),
('20180105144603'),
('20180110100416'),
('20180115104359'),
('20180116103428'),
('20180117143656'),
('20180118084155'),
('20180118085558'),
('20180118094326'),
('20180122141904'),
('20180129123349'),
('20180130141939'),
('20180201102225'),
('20180201102240'),
('20180201125117'),
('20180201140316'),
('20180201144441'),
('20180202091714'),
('20180202095300'),
('20180209093548'),
('20180209144420'),
('20180213115524'),
('20180213140231'),
('20180214101411'),
('20180214102958'),
('20180219173916'),
('20180221134258'),
('20180222154439'),
('20180227154245'),
('20180301081141'),
('20180301104411'),
('20180301125948'),
('20180301151130'),
('20180301160421'),
('20180302094032'),
('20180302094409'),
('20180302101007'),
('20180302102310'),
('20180305094634'),
('20180305112155'),
('20180305141736'),
('20180305141849'),
('20180305141922'),
('20180305150742'),
('20180305150823'),
('20180305150857'),
('20180308161947'),
('20180308162910'),
('20180314101637'),
('20180314172240'),
('20180320143832'),
('20180321142315'),
('20180321142441'),
('20180321144945'),
('20180321151016'),
('20180322113532'),
('20180322113638'),
('20180322132718'),
('20180323144835'),
('20180329125202'),
('20180404091854'),
('20180404143414'),
('20180409132339'),
('20180409160159'),
('20180410093207'),
('20180410093242'),
('20180410114152'),
('20180411144145'),
('20180411151633'),
('20180412080147'),
('20180412110423'),
('20180413094535'),
('20180413095226'),
('20180413120256'),
('20180416173637'),
('20180419153518'),
('20180419153538'),
('20180419153554'),
('20180419153616'),
('20180419153643'),
('20180420082259'),
('20180420132557'),
('20180426083300'),
('20180430090807'),
('20180503122337'),
('20180503122412'),
('20180503141345'),
('20180503141414'),
('20180503181424'),
('20180504070120'),
('20180504092030'),
('20180504133120'),
('20180504133146'),
('20180507071844'),
('20180507072724'),
('20180507072757'),
('20180507123704'),
('20180508163134'),
('20180510125036'),
('20180510164848'),
('20180514134957'),
('20180515173037'),
('20180518130726'),
('20180522141630'),
('20180523081342'),
('20180524073952'),
('20180524165119'),
('20180525103952'),
('20180525104014'),
('20180525104146'),
('20180525104346'),
('20180604160619'),
('20180606124541'),
('20180611093810'),
('20180612090621'),
('20180612090653'),
('20180614143412'),
('20180619075048'),
('20180620151531'),
('20180622081427'),
('20180622081518'),
('20180627081746'),
('20180628130228'),
('20180628130333'),
('20180628130402'),
('20180628130427'),
('20180628130450'),
('20180628130604'),
('20180702132909'),
('20180704120933'),
('20180709124500'),
('20180717140930'),
('20180718075838'),
('20180723085805'),
('20180724072817'),
('20180725124554'),
('20180726093237'),
('20180726093353'),
('20180726135009'),
('20180726135242'),
('20180814155744'),
('20180814155851'),
('20180824123012'),
('20180903101037'),
('20180903101053'),
('20180903151149'),
('20180903151217'),
('20180913133909'),
('20180913232620'),
('20180917101705'),
('20180921102202'),
('20181010103022'),
('20181017080327'),
('20181017080328'),
('20181105105247'),
('20181107102549'),
('20181107143133'),
('20181107143530'),
('20181107153237'),
('20181109123344'),
('20181113124857'),
('20181119180831'),
('20181120151944'),
('20181120171228'),
('20181122114142'),
('20181123145726'),
('20181204131342'),
('20181207081304'),
('20181210125523'),
('20181219093407'),
('20190107165648'),
('20190108125052'),
('20190108125255'),
('20190110151535'),
('20190114164237'),
('20190116152401'),
('20190129163406'),
('20190129165929'),
('20190129212144'),
('20190129212145'),
('20190129212146'),
('20190129212148'),
('20190129212149'),
('20190129212150'),
('20190129212858'),
('20190129215828'),
('20190129215830'),
('20190131092442'),
('20190204083421'),
('20190205154010'),
('20190206111149'),
('20190207082256'),
('20190213094355'),
('20190213094455'),
('20190213141635'),
('20190214153424'),
('20190215110322'),
('20190215110329'),
('20190215110346'),
('20190215110650'),
('20190215111340'),
('20190215111412'),
('20190215111526'),
('20190218122145'),
('20190218123744'),
('20190218124343'),
('20190220085608'),
('20190222093023'),
('20190307141659'),
('20190307150747'),
('20190307153922'),
('20190311172816'),
('20190311173007'),
('20190315082342'),
('20190315120122'),
('20190315124654'),
('20190321103026'),
('20190327134233'),
('20190328113147'),
('20190329113007'),
('20190401134756'),
('20190401154310'),
('20190401154320'),
('20190401154333'),
('20190401162311'),
('20190401162338'),
('20190402104906'),
('20190402105819'),
('20190402111102'),
('20190402111149'),
('20190402111401'),
('20190402113001'),
('20190402120855'),
('20190402121044'),
('20190402121217'),
('20190402121359'),
('20190403083934'),
('20190409093639'),
('20190409093650'),
('20190409093713'),
('20190409105458'),
('20190418121846'),
('20190423124211'),
('20190425090019'),
('20190426070317'),
('20190502072235'),
('20190509072038'),
('20190509150525'),
('20190510100000'),
('20190514123239'),
('20190516125751'),
('20190617134641'),
('20190619072244'),
('20190619105458'),
('20190619105620'),
('20190619105708'),
('20190626110509'),
('20190626110612'),
('20190627100046'),
('20190628081354'),
('20190701163713'),
('20190701163919'),
('20190709124651'),
('20190709132948'),
('20190709133002'),
('20190710123325'),
('20190710123350'),
('20190710123412'),
('20190710131052'),
('20190710131209'),
('20190711092941'),
('20190711111439'),
('20190716100104'),
('20190718115944'),
('20190718120027'),
('20190718120039'),
('20190718120312'),
('20190719120615'),
('20190724091123'),
('20190801145326'),
('20190802084910'),
('20190813085358'),
('20190813085435'),
('20190814121022'),
('20190815002835'),
('20190815003017'),
('20190815003135'),
('20190815143405'),
('20190815145725'),
('20190815152604'),
('20190822113257'),
('20190822113322'),
('20190822120515'),
('20190826094715'),
('20190826114916'),
('20190826115213'),
('20190827085306'),
('20190829211434'),
('20190902140820'),
('20190904092240'),
('20190911080743'),
('20190912103433'),
('20190912104953'),
('20190923073127'),
('20190923073143'),
('20190924024724'),
('20190924082259'),
('20190925071045'),
('20190925071122'),
('20190925140324'),
('20190925140335'),
('20190925142952'),
('20190926114913'),
('20191002111708'),
('20191002153904'),
('20191007131327'),
('20191010093443'),
('20191011104718'),
('20191014132821'),
('20191014145847'),
('20191015091711'),
('20191015094502'),
('20191015141824'),
('20191021090026'),
('20191021091154'),
('20191021091253'),
('20191021091328'),
('20191022161552'),
('20191023115921'),
('20191023140931'),
('20191029121012'),
('20191029121311'),
('20191029121700'),
('20191101105801'),
('20191101105955'),
('20191101110230'),
('20191101110339'),
('20191104123443'),
('20191107171315'),
('20191107171324'),
('20191111121245'),
('20191111121459'),
('20191112142919'),
('20191112143236'),
('20191112143245'),
('20191112143712'),
('20191112145526'),
('20191121162434'),
('20191129134745'),
('20191129140013'),
('20191213111544'),
('20191213112037'),
('20191230092759'),
('20191230095040'),
('20200103144746'),
('20200114112450'),
('20200119131411'),
('20200122113222'),
('20200123165138'),
('20200123171026'),
('20200127111819'),
('20200128160212'),
('20200129083327'),
('20200129111439'),
('20200131144344'),
('20200204130403'),
('20200205084242'),
('20200205111559'),
('20200205155840'),
('20200206123212'),
('20200206135755'),
('20200221141002'),
('20200221141628'),
('20200224171231'),
('20200225111407'),
('20200225154023'),
('20200226061616'),
('20200226084016'),
('20200303122356'),
('20200303122536'),
('20200303123103'),
('20200303123258'),
('20200303124459'),
('20200303132752'),
('20200303132808'),
('20200303134758'),
('20200303135014'),
('20200303153411'),
('20200303153420'),
('20200310081201'),
('20200310081811'),
('20200310105639'),
('20200311104241'),
('20200318114246'),
('20200318122257'),
('20200320095207'),
('20200320105759'),
('20200320105905'),
('20200323114925'),
('20200323145919'),
('20200323153409'),
('20200323153430'),
('20200325104317'),
('20200325104956'),
('20200326143420'),
('20200326143435'),
('20200327115052'),
('20200327115222'),
('20200402102745'),
('20200402111236'),
('20200402173954'),
('20200406122713'),
('20200406124359'),
('20200406150213'),
('20200406150258'),
('20200406150952'),
('20200407160751'),
('20200414065416'),
('20200414065633'),
('20200415071515'),
('20200415071530'),
('20200415082143'),
('20200415123041'),
('20200415133653'),
('20200415133707'),
('20200416075518'),
('20200416153906'),
('20200416154001'),
('20200416154326'),
('20200421091851'),
('20200422063816'),
('20200422084846'),
('20200422084905'),
('20200422093457'),
('20200423115528'),
('20200427104435'),
('20200428065955'),
('20200428070019'),
('20200428073831'),
('20200430074208'),
('20200504084650'),
('20200504112829'),
('20200504113220'),
('20200504113519'),
('20200508013922'),
('20200508072200'),
('20200511114249'),
('20200512111459'),
('20200519100310'),
('20200525120535'),
('20200525131533'),
('20200525132010'),
('20200525134651'),
('20200526101919'),
('20200528002404'),
('20200528012447'),
('20200528023716'),
('20200528040621'),
('20200528042631'),
('20200528045958'),
('20200528047415'),
('20200528048304'),
('20200528052736'),
('20200528054346'),
('20200528063557'),
('20200528063635'),
('20200528071334'),
('20200528084058'),
('20200528210226'),
('20200528220443'),
('20200528242316'),
('20200603060020'),
('20200603152712'),
('20200603163327'),
('20200605121911'),
('20200605122037'),
('20200610122043'),
('20200611131202'),
('20200611132239'),
('20200613161139'),
('20200613164329'),
('20200613164340'),
('20200613164349'),
('20200613164358'),
('20200613164409'),
('20200613164420'),
('20200613164627'),
('20200613164949'),
('20200613164954'),
('20200613165000'),
('20200613165005'),
('20200613165011'),
('20200613165016'),
('20200613165022'),
('20200615015501'),
('20200616133751'),
('20200617122950'),
('20200618000000'),
('20200619180935'),
('20200619191353'),
('20200619210238'),
('20200619223328'),
('20200619223501'),
('20200619224500'),
('20200619224555'),
('20200619225557'),
('20200619225813'),
('20200619225941'),
('20200622110146'),
('20200622160127'),
('20200622160255'),
('20200622160348'),
('20200623094831'),
('20200623103642'),
('20200624131753'),
('20200625091716'),
('20200626083059'),
('20200629095915'),
('20200702135636'),
('20200702135952'),
('20200703062014'),
('20200706094713'),
('20200706094923'),
('20200707162809'),
('20200707163052'),
('20200707171145'),
('20200713101428'),
('20200713103913'),
('20200713153005'),
('20200714153942'),
('20200715135058'),
('20200717141554'),
('20200720124449'),
('20200722085901'),
('20200724101455'),
('20200728145139'),
('20200805135804'),
('20200806091151'),
('20200806101120'),
('20200806101121'),
('20200806145537'),
('20200812152430'),
('20200817063118'),
('20200820155821'),
('20200820163636'),
('20200821101543'),
('20200903121658'),
('20200904120051'),
('20200907063048'),
('20200907083453'),
('20200908071608'),
('20200908072224'),
('20200909142452'),
('20200909144539'),
('20200910055552'),
('20200910060614'),
('20200910090332'),
('20200910090520'),
('20200910103015'),
('20200910103029'),
('20200911071404'),
('20200911071456'),
('20200911071505'),
('20200911073556'),
('20200911073624'),
('20200911073649'),
('20200911130537'),
('20200911131000'),
('20200911131226'),
('20200914091714'),
('20200914091732'),
('20200915102722'),
('20200915103043'),
('20200915151658'),
('20200916105620'),
('20200916105843'),
('20200921093106'),
('20200921095406'),
('20200921132558'),
('20200921133109'),
('20200922094143'),
('20200922094226'),
('20200923124503'),
('20200923124711'),
('20200924084322'),
('20200924084551'),
('20200930111524'),
('20200930111636'),
('20201005112221'),
('20201007095311'),
('20201007192043'),
('20201007192136'),
('20201007192212'),
('20201012094238'),
('20201013122604'),
('20201014100229'),
('20201015084121'),
('20201015084345'),
('20201015084420'),
('20201103130935'),
('20201103131410'),
('20201103132612'),
('20201103133017'),
('20201103133458'),
('20201103133641'),
('20201103133732'),
('20201103135019'),
('20201103135453'),
('20201103135644'),
('20201103135808'),
('20201103135909'),
('20201103140639'),
('20201103140815'),
('20201103141118'),
('20201103144141'),
('20201118173330'),
('20201123122102'),
('20201123132340'),
('20201125125500'),
('20201126093013'),
('20201203085537'),
('20201207154023'),
('20201207155947'),
('20201207170756'),
('20201208000244'),
('20201208132436'),
('20201208132454'),
('20201208141130'),
('20201208141136'),
('20201208141200'),
('20201208141224'),
('20201208141233'),
('20201208141234'),
('20201208141235'),
('20201208141236'),
('20201208141921'),
('20201208181852'),
('20201208195413'),
('20201209001010'),
('20201209104618'),
('20201209111052'),
('20201215172635'),
('20210104104843'),
('20210106142800'),
('20210107124521'),
('20210108153200'),
('20210113164927'),
('20210114100514'),
('20210118124755'),
('20210118131428'),
('20210120104101'),
('20210121134241'),
('20210122161319'),
('20210122163838'),
('20210125161336'),
('20210128140153'),
('20210129160626'),
('20210216115737');


