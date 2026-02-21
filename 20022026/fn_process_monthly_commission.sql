CREATE OR REPLACE FUNCTION fn_process_monthly_commission(
p_sales_rep_id IN NUMBER,
p_target_month IN DATE
) RETURN NUMBER IS
v_total_commission NUMBER := 0;
v_tier_multiplier NUMBER := 1.0;
v_base_sales NUMBER := 0;
v_error_msg VARCHAR2(2000);

BEGIN
-- 1. Determine base sales volume to calculate tier multiplier
SELECT NVL(SUM(deal_amount), 0)
INTO v_base_sales
FROM sales_records
WHERE rep_id = p_sales_rep_id
AND status = 'CLOSED_WON'
AND TRUNC(close_date, 'MM') = TRUNC(p_target_month, 'MM');

EXCEPTION
WHEN NO_DATA_FOUND THEN
v_error_msg := 'No active sales rep found for ID: ' || p_sales_rep_id;
INSERT INTO system_logs (log_level, msg, log_date) VALUES ('ERROR', v_error_msg, SYSDATE);
COMMIT;
RETURN 0;
WHEN OTHERS THEN
v_error_msg := 'Critical error calculating commission: ' || SQLERRM;
INSERT INTO system_logs (log_level, msg, log_date) VALUES ('FATAL', v_error_msg, SYSDATE);
COMMIT;
RAISE;
END fn_process_monthly_commission;
/