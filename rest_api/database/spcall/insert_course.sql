CREATE OR REPLACE FUNCTION insert_course(
    p_course_name VARCHAR(100)
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO courses(course_name)
    VALUES (p_course_name);
    COMMIT; -- Commit explicitly inside the stored procedure
END;
$$ LANGUAGE plpgsql;
