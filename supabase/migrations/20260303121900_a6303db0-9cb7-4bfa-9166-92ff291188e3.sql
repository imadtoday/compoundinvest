
-- Create a temporary function to fix existing campaign_answers with "Option X" values
CREATE OR REPLACE FUNCTION public.fix_option_values()
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  v_count integer := 0;
  v_rec record;
  v_new_values jsonb;
  v_letters jsonb;
  v_letter text;
  v_mapped text;
  v_code text;
BEGIN
  FOR v_rec IN
    SELECT ca.id, ca.value_json, ca.question_code
    FROM campaign_answers ca
    WHERE ca.value_json::text LIKE '%Option %'
  LOOP
    v_code := v_rec.question_code;
    v_letters := v_rec.value_json->'selected_letters';
    v_new_values := '[]'::jsonb;

    FOR i IN 0..(jsonb_array_length(v_letters) - 1) LOOP
      v_letter := v_letters->>i;
      
      -- Map letter to actual text
      v_mapped := CASE
        -- Yes/No questions
        WHEN v_code IN ('own_properties', 'finance_status') THEN
          CASE WHEN v_letter = 'Yes' THEN 'Yes' ELSE 'No' END
        -- current_focus
        WHEN v_code = 'current_focus' AND v_letter = 'A' THEN 'Building – just getting started or buying your first 1–2 properties'
        WHEN v_code = 'current_focus' AND v_letter = 'B' THEN 'Consolidating – own a few and strengthening your position'
        WHEN v_code = 'current_focus' AND v_letter = 'C' THEN 'Expanding – scaling up the portfolio with new acquisitions'
        WHEN v_code = 'current_focus' AND v_letter = 'D' THEN 'Other'
        -- timeframe
        WHEN v_code = 'timeframe' AND v_letter = 'A' THEN '0–5 years'
        WHEN v_code = 'timeframe' AND v_letter = 'B' THEN '5–10 years'
        WHEN v_code = 'timeframe' AND v_letter = 'C' THEN '10–15 years'
        WHEN v_code = 'timeframe' AND v_letter = 'D' THEN '15–25 years'
        WHEN v_code = 'timeframe' AND v_letter = 'E' THEN 'Over 25 years'
        -- investment_timing
        WHEN v_code = 'investment_timing' AND v_letter = 'A' THEN 'Immediately'
        WHEN v_code = 'investment_timing' AND v_letter = 'B' THEN 'Within 3 months'
        WHEN v_code = 'investment_timing' AND v_letter = 'C' THEN '3–6 months'
        WHEN v_code = 'investment_timing' AND v_letter = 'D' THEN '6+ months'
        -- budget_range
        WHEN v_code = 'budget_range' AND v_letter = 'A' THEN 'Under $500k'
        WHEN v_code = 'budget_range' AND v_letter = 'B' THEN '$500k–$750k'
        WHEN v_code = 'budget_range' AND v_letter = 'C' THEN '$750k–$1m'
        WHEN v_code = 'budget_range' AND v_letter = 'D' THEN '$1m–$1.5m'
        WHEN v_code = 'budget_range' AND v_letter = 'E' THEN '$1.5m+'
        -- cities
        WHEN v_code = 'cities' AND v_letter = 'A' THEN 'Sydney'
        WHEN v_code = 'cities' AND v_letter = 'B' THEN 'Melbourne'
        WHEN v_code = 'cities' AND v_letter = 'C' THEN 'Brisbane'
        WHEN v_code = 'cities' AND v_letter = 'D' THEN 'Adelaide'
        WHEN v_code = 'cities' AND v_letter = 'E' THEN 'Perth'
        WHEN v_code = 'cities' AND v_letter = 'F' THEN 'Canberra'
        WHEN v_code = 'cities' AND v_letter = 'G' THEN 'Hobart'
        WHEN v_code = 'cities' AND v_letter = 'H' THEN 'Darwin'
        WHEN v_code = 'cities' AND v_letter = 'I' THEN 'Regional areas'
        WHEN v_code = 'cities' AND v_letter = 'J' THEN 'Other'
        ELSE 'Option ' || v_letter
      END;

      v_new_values := v_new_values || to_jsonb(v_mapped);
    END LOOP;

    UPDATE campaign_answers
    SET value_json = jsonb_set(v_rec.value_json, '{selected_values}', v_new_values),
        updated_at = now()
    WHERE id = v_rec.id;

    v_count := v_count + 1;
  END LOOP;

  RETURN v_count;
END;
$$;

-- Run the fix
SELECT public.fix_option_values();

-- Drop the temporary function
DROP FUNCTION public.fix_option_values();
