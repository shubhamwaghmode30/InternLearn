


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


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."complete_subtopic_and_award_xp"("p_subtopic_id" integer) RETURNS TABLE("subtopic_completed" boolean, "topic_completed" boolean, "chapter_completed" boolean, "gained_xp" integer, "total_xp" integer)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$declare
  v_user uuid := auth.uid();
  v_topic_id integer;
  v_chapter_id integer;
  v_subtopic_xp integer := 0;
  v_topic_xp integer := 0;
  v_chapter_xp integer := 0;
  v_gained integer := 0;

  v_inserted_subtopic integer;
  v_inserted_topic integer;
  v_inserted_chapter integer;

  v_topic_total integer := 0;
  v_topic_done integer := 0;
  v_chapter_total integer := 0;
  v_chapter_done integer := 0;
begin
  if v_user is null then
    raise exception 'Authentication required';
  end if;

  perform public.ensure_user_profile(v_user);

  select s.topic_id, t.chapter_id, s.xp_reward
    into v_topic_id, v_chapter_id, v_subtopic_xp
  from public.subtopic s
  join public.topic t on t.id = s.topic_id
  where s.id = p_subtopic_id;

  if v_topic_id is null then
    raise exception 'Invalid subtopic id: %', p_subtopic_id;
  end if;

  insert into public.user_subtopic_progress(user_id, subtopic_id, xp_earned)
  values (v_user, p_subtopic_id, v_subtopic_xp)
  on conflict (user_id, subtopic_id) do nothing
  returning 1 into v_inserted_subtopic;

  if v_inserted_subtopic is not null then
    v_gained := v_gained + v_subtopic_xp;

    update public.user_profile up
    set total_xp = up.total_xp + v_subtopic_xp
    where up.user_id = v_user;
  end if;

  select count(*) into v_topic_total
  from public.subtopic s
  where s.topic_id = v_topic_id;

  select count(*) into v_topic_done
  from public.user_subtopic_progress usp
  join public.subtopic s on s.id = usp.subtopic_id
  where usp.user_id = v_user
    and s.topic_id = v_topic_id;

  if v_topic_total > 0 and v_topic_total = v_topic_done then
    select xp_reward into v_topic_xp
    from public.topic
    where id = v_topic_id;

    insert into public.user_topic_progress(user_id, topic_id, xp_earned)
    values (v_user, v_topic_id, v_topic_xp)
    on conflict (user_id, topic_id) do nothing
    returning 1 into v_inserted_topic;

    if v_inserted_topic is not null then
      v_gained := v_gained + v_topic_xp;

      update public.user_profile up
      set total_xp = up.total_xp + v_topic_xp
      where up.user_id = v_user;
    end if;
  end if;

  select count(*) into v_chapter_total
  from public.topic t
  where t.chapter_id = v_chapter_id;

  select count(*) into v_chapter_done
  from public.user_topic_progress utp
  join public.topic t on t.id = utp.topic_id
  where utp.user_id = v_user
    and t.chapter_id = v_chapter_id;

  if v_chapter_total > 0 and v_chapter_total = v_chapter_done then
    select xp_reward into v_chapter_xp
    from public.chapter
    where id = v_chapter_id;

    insert into public.user_chapter_progress(user_id, chapter_id, xp_earned)
    values (v_user, v_chapter_id, v_chapter_xp)
    on conflict (user_id, chapter_id) do nothing
    returning 1 into v_inserted_chapter;

    if v_inserted_chapter is not null then
      v_gained := v_gained + v_chapter_xp;

      update public.user_profile up
      set total_xp = up.total_xp + v_chapter_xp
      where up.user_id = v_user;
    end if;
  end if;

  return query
  select
    (v_inserted_subtopic is not null) as subtopic_completed,
    (v_inserted_topic is not null) as topic_completed,
    (v_inserted_chapter is not null) as chapter_completed,
    v_gained as gained_xp,
    (
      select up.total_xp
      from public.user_profile up
      where up.user_id = v_user
    ) as total_xp;
end;$$;


ALTER FUNCTION "public"."complete_subtopic_and_award_xp"("p_subtopic_id" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."ensure_user_profile"("p_user_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  insert into public.user_profile(user_id, total_xp)
  values (p_user_id, 0)
  on conflict (user_id) do nothing;
end;
$$;


ALTER FUNCTION "public"."ensure_user_profile"("p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_progress_summary"() RETURNS TABLE("total_xp" integer, "completed_subtopics" integer, "completed_topics" integer, "completed_chapters" integer)
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select
    coalesce((select up.total_xp from public.user_profile up where up.user_id = auth.uid()), 0) as total_xp,
    coalesce((select count(*)::int from public.user_subtopic_progress usp where usp.user_id = auth.uid()), 0) as completed_subtopics,
    coalesce((select count(*)::int from public.user_topic_progress utp where utp.user_id = auth.uid()), 0) as completed_topics,
    coalesce((select count(*)::int from public.user_chapter_progress ucp where ucp.user_id = auth.uid()), 0) as completed_chapters;
$$;


ALTER FUNCTION "public"."get_my_progress_summary"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_recent_completed_lessons"() RETURNS TABLE("lesson_type" "text", "subject_name" "text", "chapter_name" "text", "topic_name" "text", "lesson_title" "text", "xp_earned" integer, "completed_at" timestamp with time zone)
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select 'subtopic'::text as lesson_type,
         s.name::text as subject_name,
         c.name::text as chapter_name,
         t.title::text as topic_name,
         st.title::text as lesson_title,
         usp.xp_earned,
         usp.completed_at
  from public.user_subtopic_progress usp
  join public.subtopic st on st.id = usp.subtopic_id
  join public.topic t on t.id = st.topic_id
  join public.chapter c on c.id = t.chapter_id
  join public.subject s on s.id = c.subject_id
  where usp.user_id = auth.uid()

  union all

  select 'topic'::text as lesson_type,
         s.name::text as subject_name,
         c.name::text as chapter_name,
         t.title::text as topic_name,
         t.title::text as lesson_title,
         utp.xp_earned,
         utp.completed_at
  from public.user_topic_progress utp
  join public.topic t on t.id = utp.topic_id
  join public.chapter c on c.id = t.chapter_id
  join public.subject s on s.id = c.subject_id
  where utp.user_id = auth.uid()

  union all

  select 'chapter'::text as lesson_type,
         s.name::text as subject_name,
         c.name::text as chapter_name,
         ''::text as topic_name,
         c.name::text as lesson_title,
         ucp.xp_earned,
         ucp.completed_at
  from public.user_chapter_progress ucp
  join public.chapter c on c.id = ucp.chapter_id
  join public.subject s on s.id = c.subject_id
  where ucp.user_id = auth.uid()

  order by completed_at desc;
$$;


ALTER FUNCTION "public"."get_recent_completed_lessons"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_weekly_subject_progress"() RETURNS TABLE("subject_id" integer, "subject_name" "text", "day_bucket" "date", "xp_earned" integer, "lesson_count" integer)
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  with subtopic_progress as (
    select
      s.id as subject_id,
      s.name as subject_name,
      date_trunc('day', usp.completed_at)::date as day_bucket,
      coalesce(usp.xp_earned, 0) as xp_earned,
      1 as lesson_count
    from public.user_subtopic_progress usp
    join public.subtopic st on st.id = usp.subtopic_id
    join public.topic t on t.id = st.topic_id
    join public.chapter c on c.id = t.chapter_id
    join public.subject s on s.id = c.subject_id
    where usp.user_id = auth.uid()
      and usp.completed_at >= now() - interval '6 days'
  ),
  topic_progress as (
    select
      s.id as subject_id,
      s.name as subject_name,
      date_trunc('day', utp.completed_at)::date as day_bucket,
      coalesce(utp.xp_earned, 0) as xp_earned,
      1 as lesson_count
    from public.user_topic_progress utp
    join public.topic t on t.id = utp.topic_id
    join public.chapter c on c.id = t.chapter_id
    join public.subject s on s.id = c.subject_id
    where utp.user_id = auth.uid()
      and utp.completed_at >= now() - interval '6 days'
  ),
  chapter_progress as (
    select
      s.id as subject_id,
      s.name as subject_name,
      date_trunc('day', ucp.completed_at)::date as day_bucket,
      coalesce(ucp.xp_earned, 0) as xp_earned,
      1 as lesson_count
    from public.user_chapter_progress ucp
    join public.chapter c on c.id = ucp.chapter_id
    join public.subject s on s.id = c.subject_id
    where ucp.user_id = auth.uid()
      and ucp.completed_at >= now() - interval '6 days'
  )
  select
    subject_id,
    subject_name,
    day_bucket,
    sum(xp_earned)::int as xp_earned,
    sum(lesson_count)::int as lesson_count
  from (
    select * from subtopic_progress
    union all
    select * from topic_progress
    union all
    select * from chapter_progress
  ) combined
  group by subject_id, subject_name, day_bucket
  order by day_bucket asc, subject_name asc;
$$;


ALTER FUNCTION "public"."get_weekly_subject_progress"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  new.updated_at = now();
  return new;
end;
$$;


ALTER FUNCTION "public"."set_updated_at"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."chapter" (
    "id" integer NOT NULL,
    "subject_id" integer NOT NULL,
    "chapter_number" bigint NOT NULL,
    "name" "text" NOT NULL,
    "xp_reward" integer DEFAULT 0 NOT NULL
);


ALTER TABLE "public"."chapter" OWNER TO "postgres";


ALTER TABLE "public"."chapter" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."chapter_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."slide" (
    "id" integer NOT NULL,
    "subtopic_id" integer NOT NULL,
    "title" "text" NOT NULL,
    "order" integer NOT NULL,
    "body_md" "jsonb" NOT NULL,
    "key_points" "jsonb" NOT NULL
);


ALTER TABLE "public"."slide" OWNER TO "postgres";


ALTER TABLE "public"."slide" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."slide_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."slide_match" (
    "id" integer NOT NULL,
    "question" "text",
    "left_items" "jsonb",
    "right_items" "jsonb",
    "correct_pairs" "jsonb",
    "explanation_md" "text" NOT NULL,
    "order" bigint,
    "subtopic_id" integer
);


ALTER TABLE "public"."slide_match" OWNER TO "postgres";


ALTER TABLE "public"."slide_match" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."slide_match_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."slide_mcq" (
    "id" integer NOT NULL,
    "question_md" "text" NOT NULL,
    "option_a" "text" NOT NULL,
    "option_b" "text" NOT NULL,
    "option_c" "text" NOT NULL,
    "option_d" "text" NOT NULL,
    "correct_option" character(1) NOT NULL,
    "explanation_md" "text" NOT NULL,
    "order" integer NOT NULL,
    "subtopic_id" integer NOT NULL,
    CONSTRAINT "slide_mcq_correct_option_check" CHECK (("correct_option" = ANY (ARRAY['a'::"bpchar", 'b'::"bpchar", 'c'::"bpchar", 'd'::"bpchar"])))
);


ALTER TABLE "public"."slide_mcq" OWNER TO "postgres";


ALTER TABLE "public"."slide_mcq" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."slide_mcq_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."subject" (
    "id" integer NOT NULL,
    "name" character varying(255) NOT NULL,
    "description" "text"
);


ALTER TABLE "public"."subject" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."subject_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."subject_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."subject_id_seq" OWNED BY "public"."subject"."id";



CREATE TABLE IF NOT EXISTS "public"."subtopic" (
    "id" integer NOT NULL,
    "title" character varying(255) NOT NULL,
    "topic_id" integer NOT NULL,
    "order" integer,
    "xp_reward" integer DEFAULT 0 NOT NULL
);


ALTER TABLE "public"."subtopic" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."subtopic_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."subtopic_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."subtopic_id_seq" OWNED BY "public"."subtopic"."id";



CREATE TABLE IF NOT EXISTS "public"."topic" (
    "id" integer NOT NULL,
    "chapter_id" integer NOT NULL,
    "title" "text" NOT NULL,
    "xp_reward" integer DEFAULT 0 NOT NULL
);


ALTER TABLE "public"."topic" OWNER TO "postgres";


ALTER TABLE "public"."topic" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."topic_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."user_chapter_progress" (
    "user_id" "uuid" NOT NULL,
    "chapter_id" integer NOT NULL,
    "xp_earned" integer DEFAULT 0 NOT NULL,
    "completed_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_chapter_progress" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_profile" (
    "user_id" "uuid" NOT NULL,
    "total_xp" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "email" "text" DEFAULT ''::"text",
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "avatar_seed" "text" DEFAULT ''::"text" NOT NULL
);


ALTER TABLE "public"."user_profile" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_subtopic_progress" (
    "user_id" "uuid" NOT NULL,
    "subtopic_id" integer NOT NULL,
    "xp_earned" integer DEFAULT 0 NOT NULL,
    "completed_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_subtopic_progress" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_topic_progress" (
    "user_id" "uuid" NOT NULL,
    "topic_id" integer NOT NULL,
    "xp_earned" integer DEFAULT 0 NOT NULL,
    "completed_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."user_topic_progress" OWNER TO "postgres";


ALTER TABLE ONLY "public"."subject" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."subject_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."subtopic" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."subtopic_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."chapter"
    ADD CONSTRAINT "chapter_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."slide_match"
    ADD CONSTRAINT "slide_match_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."slide_mcq"
    ADD CONSTRAINT "slide_mcq_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."slide"
    ADD CONSTRAINT "slide_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."subject"
    ADD CONSTRAINT "subject_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."subtopic"
    ADD CONSTRAINT "subtopic_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."topic"
    ADD CONSTRAINT "topic_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_chapter_progress"
    ADD CONSTRAINT "user_chapter_progress_pkey" PRIMARY KEY ("user_id", "chapter_id");



ALTER TABLE ONLY "public"."user_profile"
    ADD CONSTRAINT "user_profile_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."user_subtopic_progress"
    ADD CONSTRAINT "user_subtopic_progress_pkey" PRIMARY KEY ("user_id", "subtopic_id");



ALTER TABLE ONLY "public"."user_topic_progress"
    ADD CONSTRAINT "user_topic_progress_pkey" PRIMARY KEY ("user_id", "topic_id");



CREATE INDEX "idx_user_chapter_progress_user" ON "public"."user_chapter_progress" USING "btree" ("user_id");



CREATE INDEX "idx_user_subtopic_progress_user" ON "public"."user_subtopic_progress" USING "btree" ("user_id");



CREATE INDEX "idx_user_topic_progress_user" ON "public"."user_topic_progress" USING "btree" ("user_id");



CREATE OR REPLACE TRIGGER "trg_user_profile_updated_at" BEFORE UPDATE ON "public"."user_profile" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



ALTER TABLE ONLY "public"."chapter"
    ADD CONSTRAINT "chapter_subject_fk" FOREIGN KEY ("subject_id") REFERENCES "public"."subject"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."slide_match"
    ADD CONSTRAINT "slide_match_subtopic_id_fkey" FOREIGN KEY ("subtopic_id") REFERENCES "public"."subtopic"("id");



ALTER TABLE ONLY "public"."slide_mcq"
    ADD CONSTRAINT "slide_mcq_subtopic_id_fkey" FOREIGN KEY ("subtopic_id") REFERENCES "public"."subtopic"("id");



ALTER TABLE ONLY "public"."slide"
    ADD CONSTRAINT "slide_subtopic_fk" FOREIGN KEY ("subtopic_id") REFERENCES "public"."subtopic"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."subtopic"
    ADD CONSTRAINT "subtopic_topic_id_fkey" FOREIGN KEY ("topic_id") REFERENCES "public"."topic"("id");



ALTER TABLE ONLY "public"."topic"
    ADD CONSTRAINT "topic_chapter_fk" FOREIGN KEY ("chapter_id") REFERENCES "public"."chapter"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_chapter_progress"
    ADD CONSTRAINT "user_chapter_progress_chapter_id_fkey" FOREIGN KEY ("chapter_id") REFERENCES "public"."chapter"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_chapter_progress"
    ADD CONSTRAINT "user_chapter_progress_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_profile"
    ADD CONSTRAINT "user_profile_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_subtopic_progress"
    ADD CONSTRAINT "user_subtopic_progress_subtopic_id_fkey" FOREIGN KEY ("subtopic_id") REFERENCES "public"."subtopic"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_subtopic_progress"
    ADD CONSTRAINT "user_subtopic_progress_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_topic_progress"
    ADD CONSTRAINT "user_topic_progress_topic_id_fkey" FOREIGN KEY ("topic_id") REFERENCES "public"."topic"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_topic_progress"
    ADD CONSTRAINT "user_topic_progress_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



CREATE POLICY "Enable read access for all users" ON "public"."chapter" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."slide" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."slide_match" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."slide_mcq" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."subject" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."subtopic" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."topic" FOR SELECT USING (true);



ALTER TABLE "public"."chapter" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."slide" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."slide_match" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."slide_mcq" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."subject" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."subtopic" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."topic" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

GRANT ALL ON FUNCTION "public"."complete_subtopic_and_award_xp"("p_subtopic_id" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."complete_subtopic_and_award_xp"("p_subtopic_id" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."complete_subtopic_and_award_xp"("p_subtopic_id" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."ensure_user_profile"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."ensure_user_profile"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."ensure_user_profile"("p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_my_progress_summary"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_progress_summary"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_progress_summary"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_recent_completed_lessons"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_recent_completed_lessons"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_recent_completed_lessons"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_weekly_subject_progress"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_weekly_subject_progress"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_weekly_subject_progress"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "service_role";

GRANT ALL ON TABLE "public"."chapter" TO "anon";
GRANT ALL ON TABLE "public"."chapter" TO "authenticated";
GRANT ALL ON TABLE "public"."chapter" TO "service_role";



GRANT ALL ON SEQUENCE "public"."chapter_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."chapter_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."chapter_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."slide" TO "anon";
GRANT ALL ON TABLE "public"."slide" TO "authenticated";
GRANT ALL ON TABLE "public"."slide" TO "service_role";



GRANT ALL ON SEQUENCE "public"."slide_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."slide_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."slide_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."slide_match" TO "anon";
GRANT ALL ON TABLE "public"."slide_match" TO "authenticated";
GRANT ALL ON TABLE "public"."slide_match" TO "service_role";



GRANT ALL ON SEQUENCE "public"."slide_match_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."slide_match_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."slide_match_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."slide_mcq" TO "anon";
GRANT ALL ON TABLE "public"."slide_mcq" TO "authenticated";
GRANT ALL ON TABLE "public"."slide_mcq" TO "service_role";



GRANT ALL ON SEQUENCE "public"."slide_mcq_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."slide_mcq_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."slide_mcq_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."subject" TO "anon";
GRANT ALL ON TABLE "public"."subject" TO "authenticated";
GRANT ALL ON TABLE "public"."subject" TO "service_role";



GRANT ALL ON SEQUENCE "public"."subject_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."subject_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."subject_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."subtopic" TO "anon";
GRANT ALL ON TABLE "public"."subtopic" TO "authenticated";
GRANT ALL ON TABLE "public"."subtopic" TO "service_role";



GRANT ALL ON SEQUENCE "public"."subtopic_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."subtopic_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."subtopic_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."topic" TO "anon";
GRANT ALL ON TABLE "public"."topic" TO "authenticated";
GRANT ALL ON TABLE "public"."topic" TO "service_role";



GRANT ALL ON SEQUENCE "public"."topic_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."topic_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."topic_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."user_chapter_progress" TO "anon";
GRANT ALL ON TABLE "public"."user_chapter_progress" TO "authenticated";
GRANT ALL ON TABLE "public"."user_chapter_progress" TO "service_role";



GRANT ALL ON TABLE "public"."user_profile" TO "anon";
GRANT ALL ON TABLE "public"."user_profile" TO "authenticated";
GRANT ALL ON TABLE "public"."user_profile" TO "service_role";



GRANT ALL ON TABLE "public"."user_subtopic_progress" TO "anon";
GRANT ALL ON TABLE "public"."user_subtopic_progress" TO "authenticated";
GRANT ALL ON TABLE "public"."user_subtopic_progress" TO "service_role";



GRANT ALL ON TABLE "public"."user_topic_progress" TO "anon";
GRANT ALL ON TABLE "public"."user_topic_progress" TO "authenticated";
GRANT ALL ON TABLE "public"."user_topic_progress" TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";
