
-- 10_enrolment_automation.sql
-- Registration threshold: KES 2,500.
-- Attendance activates a Registered enrolment.

-- Recalculate an enrolment's registration status
-- whenever its payment records change.
CREATE OR REPLACE FUNCTION refresh_enrolment_registration(
    p_enrolment_id VARCHAR(15)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_paid NUMERIC(12,2);
    v_status VARCHAR(20);
    v_has_present BOOLEAN;
BEGIN
    SELECT COALESCE(SUM(amount), 0)
    INTO v_total_paid
    FROM payments
    WHERE enrolment_id = p_enrolment_id;

    SELECT status
    INTO v_status
    FROM enrolments
    WHERE enrolment_id = p_enrolment_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN;
    END IF;

    SELECT EXISTS (
        SELECT 1
        FROM attendance
        WHERE enrolment_id = p_enrolment_id
          AND attendance_status = 'Present'
    )
    INTO v_has_present;

    IF v_status = 'Enquiry' AND v_total_paid >= 2500 THEN
        IF v_has_present THEN
            UPDATE enrolments
            SET status = 'Active'
            WHERE enrolment_id = p_enrolment_id;
        ELSE
            UPDATE enrolments
            SET status = 'Registered'
            WHERE enrolment_id = p_enrolment_id;
        END IF;

    ELSIF v_status = 'Registered' AND v_has_present THEN
        UPDATE enrolments
        SET status = 'Active'
        WHERE enrolment_id = p_enrolment_id;

    ELSIF v_status = 'Registered'
          AND v_total_paid < 2500
          AND NOT v_has_present THEN
        UPDATE enrolments
        SET status = 'Enquiry'
        WHERE enrolment_id = p_enrolment_id;
    END IF;
END;
$$;


-- React to payment insertion, correction or deletion.
CREATE OR REPLACE FUNCTION trg_refresh_registration_after_payment()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        PERFORM refresh_enrolment_registration(NEW.enrolment_id);
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        PERFORM refresh_enrolment_registration(OLD.enrolment_id);
        RETURN OLD;

    ELSE
        PERFORM refresh_enrolment_registration(OLD.enrolment_id);

        IF NEW.enrolment_id IS DISTINCT FROM OLD.enrolment_id THEN
            PERFORM refresh_enrolment_registration(NEW.enrolment_id);
        END IF;

        RETURN NEW;
    END IF;
END;
$$;

CREATE TRIGGER payments_registration_status_trigger
AFTER INSERT OR UPDATE OR DELETE ON payments
FOR EACH ROW
EXECUTE FUNCTION trg_refresh_registration_after_payment();


-- Do not allow attendance to be recorded while an enrolment
-- is still an Enquiry.
CREATE OR REPLACE FUNCTION trg_check_attendance_eligibility()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_status VARCHAR(20);
BEGIN
    SELECT status
    INTO v_status
    FROM enrolments
    WHERE enrolment_id = NEW.enrolment_id;

    IF v_status = 'Enquiry' THEN
        RAISE EXCEPTION
            'Attendance cannot be recorded for enrolment % while its status is Enquiry',
            NEW.enrolment_id;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER attendance_eligibility_trigger
BEFORE INSERT OR UPDATE ON attendance
FOR EACH ROW
EXECUTE FUNCTION trg_check_attendance_eligibility();


-- First Present attendance activates a Registered enrolment.
CREATE OR REPLACE FUNCTION trg_activate_on_present_attendance()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.attendance_status = 'Present' THEN
        UPDATE enrolments
        SET status = 'Active'
        WHERE enrolment_id = NEW.enrolment_id
          AND status = 'Registered';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER attendance_activation_trigger
AFTER INSERT OR UPDATE ON attendance
FOR EACH ROW
EXECUTE FUNCTION trg_activate_on_present_attendance();
