# -*- coding: utf-8 -*-
"""Tests del analizador estático v3.0.0 (SPEC_v3 §11).

Los zips sintéticos se construyen en tmp con XML mínimo que sigue la
estructura real de los exports (SPEC §2/§3).
"""
import json
import os
import sys
import tempfile
import unittest
import zipfile
from datetime import datetime, timedelta

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))
import appian_static_analyzer as A  # noqa: E402

FIXTURES = os.path.join(os.path.dirname(__file__), "..", "fixtures")


def pm_xml(name="PKG Proceso", uuid="00000000-0000-0000-0000-0000000000pm",
           custom="true", people=('<people><type>4096</type>'
                                  '<stringId>GRP_OK</stringId></people>'),
           recipients_exp="", cleanup="2", delete_delay="1", nodes=""):
    nodes = nodes or ('<node uuid="n1"><ac><local-id>core.0</local-id>'
                      '<name>Start Node</name></ac><pre-triggers/><escalations/>'
                      '<deadline><enabled>false</enabled><type>0</type>'
                      '<units>0</units></deadline></node>')
    return f"""<?xml version="1.0"?>
<processModelHaul><process_model_port><pm>
<meta><uuid><![CDATA[{uuid}]]></uuid>
<name><string-map><pair><locale lang="es"/><value><![CDATA[{name}]]></value></pair></string-map></name>
<pm-notification-settings><custom-settings>{custom}</custom-settings>
<usersandgroups>{people}</usersandgroups>
<recipients-exp>{recipients_exp}</recipients-exp></pm-notification-settings>
<cleanup-action>{cleanup}</cleanup-action><auto-archive-delay>7</auto-archive-delay>
<auto-delete-delay>{delete_delay}</auto-delete-delay>
<timeZoneId><![CDATA[Europe/Madrid]]></timeZoneId></meta>
<nodes>{nodes}</nodes></pm></process_model_port></processModelHaul>"""


def group_xml(name, uuid):
    return (f'<?xml version="1.0"?><groupHaul><group><name>{name}</name>'
            f'<uuid>{uuid}</uuid></group></groupHaul>')


def record_xml(name, replica=True, activated="false", value='{}'):
    src = ('<a:source xmlns:a="http://www.appian.com/ae/types/2009" '
           'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
           'xsi:type="a:RecordsReplica"/>') if replica else '<a:source/>'
    return f'''<?xml version="1.0"?>
<recordTypeHaul xmlns:a="http://www.appian.com/ae/types/2009">
<recordType a:uuid="RT-{name}" name="{name}">{src}
<a:sourceType>RDBMS_TABLE</a:sourceType>
<a:sourceConfiguration><refreshSchedule><value><![CDATA[{value}]]></value>
<activated>{activated}</activated></refreshSchedule></a:sourceConfiguration>
</recordType></recordTypeHaul>'''


def constant_xml(name, value, type_name="Text"):
    return (f'<?xml version="1.0"?><contentHaul><constant><name>{name}</name>'
            f'<uuid>CONST-{name}</uuid><typedValue><name>{type_name}</name>'
            f'<value><![CDATA[{value}]]></value></typedValue>'
            f'</constant></contentHaul>')


def rule_xml(name, definition="1", uuid=None):
    uuid = uuid or f"RULE-{name}"
    return (f'<?xml version="1.0"?><ruleHaul><rule><name>{name}</name>'
            f'<uuid>{uuid}</uuid><definition><![CDATA[{definition}]]></definition>'
            f'</rule></ruleHaul>')


def export_log(items):
    lines = [f'content {i} {u} "{n}"' for i, (n, u) in enumerate(items, 1)]
    return "Éxito (%d):\n" % len(items) + "\n".join(lines) + "\n"


def make_zip(files, tmp, name="pkg.zip"):
    path = os.path.join(tmp, name)
    with zipfile.ZipFile(path, "w") as zf:
        for rel, content in files.items():
            zf.writestr(rel, content)
    return path


def run(files, tmp, extra_args=None, name="pkg.zip"):
    zip_path = make_zip(files, tmp, name)
    out = os.path.join(tmp, "out.json")
    argv = [zip_path, "-o", out, "--quiet"] + (extra_args or [])
    code = A.main(argv)
    return code, json.load(open(out))


def gates(report):
    return {g["id"]: g["status"] for g in report["deploymentGate"]["gates"]}


def findings(report, check):
    return [f for f in report["findings"] if f["checkId"] == check]


class TestForEach(unittest.TestCase):
    def test_query_in_items_no_prf002(self):
        with tempfile.TemporaryDirectory() as t:
            d = ('a!forEach(items: a!queryRecordType(recordType: #"urn:x").data, '
                 'expression: fv!item)')
            _, r = run({"content/r.xml": rule_xml("PKG_R1", d)}, t)
            self.assertEqual(findings(r, "PRF-002"), [])

    def test_query_in_expression_prf002(self):
        with tempfile.TemporaryDirectory() as t:
            d = ('a!forEach(items: {1,2}, expression: a!queryEntity('
                 'entity: cons!PKG_E, query: a!query()))')
            _, r = run({"content/r.xml": rule_xml("PKG_R1", d)}, t)
            self.assertTrue(findings(r, "PRF-002"))


class TestVerdictHeuristic(unittest.TestCase):
    def test_high_heuristic_not_blocking(self):
        with tempfile.TemporaryDirectory() as t:
            d = 'a!queryEntity(entity: cons!PKG_E, pagingInfo: a!pagingInfo(batchSize: -1))'
            files = {"content/r.xml": rule_xml("PKG_R1", d)}
            _, r = run(files, t)
            self.assertTrue(findings(r, "PRF-001"))
            self.assertEqual(r["deploymentGate"]["verdict"], "APTO_CON_CONDICIONES")
            # G01/G02/G06 son REVIEW; ningún FAIL => no NO_APTO


class TestBatch(unittest.TestCase):
    def _zip(self, trigger_xml, tmp, local_id="core.0"):
        node = (f'<node uuid="n1"><ac><local-id>{local_id}</local-id>'
                f'<name>Start Node</name></ac><pre-triggers>'
                f'<timer-trigger index="0">{trigger_xml}</timer-trigger>'
                f'</pre-triggers><escalations/>'
                f'<deadline><enabled>false</enabled><type>0</type><units>0</units>'
                f'</deadline></node>')
        return run({"processModel/p.xml": pm_xml(nodes=node)}, tmp)

    def test_non_recurring_no_batch(self):
        with tempfile.TemporaryDirectory() as t:
            _, r = self._zip('<schedule isRecurring="false"><interval>'
                             '<minutes>5</minutes></interval></schedule>', t)
            self.assertEqual(findings(r, "PM-010"), [])
            self.assertEqual(findings(r, "PM-011"), [])
            self.assertEqual(gates(r)["G10"], "NA")

    def test_daily_1000_utc_fails(self):
        with tempfile.TemporaryDirectory() as t:
            rec = ('<schedule isRecurring="true"/><recurrence><recurring-interval '
                   'type="1"><daily><day-interval>1</day-interval></daily>'
                   '<time>10:00:00Z</time></recurring-interval><timeZoneId/>'
                   '<timeZoneIdExpr><![CDATA[=pm!timezone]]></timeZoneIdExpr>'
                   '</recurrence>')
            _, r = self._zip(rec, t)
            f11 = findings(r, "PM-011")
            self.assertTrue(any(f["gateStatus"] == "FAIL" for f in f11))
            self.assertEqual(gates(r)["G10"], "FAIL")

    def test_daily_0100_utc_passes(self):
        with tempfile.TemporaryDirectory() as t:
            rec = ('<schedule isRecurring="true"/><recurrence><recurring-interval '
                   'type="1"><daily><day-interval>1</day-interval></daily>'
                   '<time>01:00:00Z</time></recurring-interval><timeZoneId/>'
                   '<timeZoneIdExpr><![CDATA[=pm!timezone]]></timeZoneIdExpr>'
                   '</recurrence>')
            _, r = self._zip(rec, t)
            self.assertTrue(findings(r, "PM-010"))
            self.assertFalse([f for f in findings(r, "PM-011")
                              if f["gateStatus"] == "FAIL"])
            self.assertEqual(gates(r)["G10"], "PASS")

    def test_timeexpr_literal_passes(self):
        with tempfile.TemporaryDirectory() as t:
            rec = ('<schedule isRecurring="true"/><recurrence><recurring-interval '
                   'type="2"><weekly><week-interval>1</week-interval></weekly>'
                   '<timeExpr><![CDATA[="05:30 AM"]]></timeExpr></recurring-interval>'
                   '<timeZoneId/><timeZoneIdExpr><![CDATA[=pm!timezone]]>'
                   '</timeZoneIdExpr></recurrence>')
            _, r = self._zip(rec, t)
            self.assertEqual(gates(r)["G10"], "PASS")

    def test_timeexpr_expression_review(self):
        with tempfile.TemporaryDirectory() as t:
            rec = ('<schedule isRecurring="true"/><recurrence><recurring-interval '
                   'type="1"><daily><day-interval>1</day-interval></daily>'
                   '<timeExpr><![CDATA[=pv!hora]]></timeExpr></recurring-interval>'
                   '<timeZoneId/><timeZoneIdExpr><![CDATA[=pm!timezone]]>'
                   '</timeZoneIdExpr></recurrence>')
            _, r = self._zip(rec, t)
            self.assertTrue(any(f["gateStatus"] == "REVIEW"
                                for f in findings(r, "PM-011")))
            self.assertEqual(gates(r)["G10"], "REVIEW")

    def test_dynamic_timezone_review(self):
        with tempfile.TemporaryDirectory() as t:
            rec = ('<schedule isRecurring="true"/><recurrence><recurring-interval '
                   'type="1"><daily><day-interval>1</day-interval></daily>'
                   '<time>01:00:00Z</time></recurring-interval><timeZoneId/>'
                   '<timeZoneIdExpr><![CDATA[=cons!PKG_TZ]]></timeZoneIdExpr>'
                   '</recurrence>')
            _, r = self._zip(rec, t)
            self.assertEqual(gates(r)["G10"], "REVIEW")

    def test_dst_ambiguous_review(self):
        # 05:00Z -> 07:00 en verano (dentro) / 06:00 en invierno (fuera)
        with tempfile.TemporaryDirectory() as t:
            rec = ('<schedule isRecurring="true"/><recurrence><recurring-interval '
                   'type="1"><daily><day-interval>1</day-interval></daily>'
                   '<time>05:00:00Z</time></recurring-interval><timeZoneId/>'
                   '<timeZoneIdExpr><![CDATA[=pm!timezone]]></timeZoneIdExpr>'
                   '</recurrence>')
            _, r = self._zip(rec, t)
            self.assertTrue(any(f["gateStatus"] == "REVIEW"
                                for f in findings(r, "PM-011")))
            self.assertEqual(gates(r)["G10"], "REVIEW")

    def test_recurring_non_start_pm013(self):
        with tempfile.TemporaryDirectory() as t:
            _, r = self._zip('<schedule isRecurring="true"><interval><minutes>1'
                             '</minutes></interval></schedule><recurrence/>',
                             t, local_id="internal.16")
            self.assertTrue(findings(r, "PM-013"))
            self.assertEqual(gates(r)["G10"], "NA")


class TestCleanup(unittest.TestCase):
    def _run(self, tmp, cleanup, delay):
        return run({"processModel/p.xml": pm_xml(cleanup=cleanup,
                                                 delete_delay=delay)}, tmp)

    def test_delete_1_pass(self):
        with tempfile.TemporaryDirectory() as t:
            _, r = self._run(t, "2", "1")
            self.assertEqual(gates(r)["G04"], "PASS")

    def test_delete_5_fail(self):
        with tempfile.TemporaryDirectory() as t:
            _, r = self._run(t, "2", "5")
            self.assertEqual(gates(r)["G04"], "FAIL")

    def test_archive_fail(self):
        with tempfile.TemporaryDirectory() as t:
            _, r = self._run(t, "1", "3")
            self.assertEqual(gates(r)["G04"], "FAIL")

    def test_default_fail(self):
        with tempfile.TemporaryDirectory() as t:
            _, r = self._run(t, "3", "1")
            self.assertEqual(gates(r)["G04"], "FAIL")

    def test_absent_review(self):
        with tempfile.TemporaryDirectory() as t:
            xml = pm_xml().replace("<cleanup-action>2</cleanup-action>", "")
            _, r = run({"processModel/p.xml": xml}, t)
            self.assertEqual(gates(r)["G04"], "REVIEW")


class TestAlertGroup(unittest.TestCase):
    def _run(self, tmp, files):
        return run(files, tmp)

    def test_custom_false_fail(self):
        with tempfile.TemporaryDirectory() as t:
            _, r = self._run(t, {"processModel/p.xml": pm_xml(custom="false")})
            self.assertEqual(gates(r)["G03"], "FAIL")

    def test_administrators_fail(self):
        with tempfile.TemporaryDirectory() as t:
            files = {"processModel/p.xml": pm_xml(
                people='<people><type>4096</type><stringId>G1</stringId></people>'),
                "group/g.xml": group_xml("Administrators", "G1")}
            _, r = self._run(t, files)
            self.assertEqual(gates(r)["G03"], "FAIL")

    def test_system_group_uuid_fail(self):
        with tempfile.TemporaryDirectory() as t:
            files = {"processModel/p.xml": pm_xml(
                people='<people><type>4096</type>'
                       '<stringId>SYSTEM_GROUP_ADMINISTRATORS</stringId></people>')}
            _, r = self._run(t, files)
            self.assertEqual(gates(r)["G03"], "FAIL")

    def test_app_admin_group_pass_pm012(self):
        with tempfile.TemporaryDirectory() as t:
            files = {"processModel/p.xml": pm_xml(
                people='<people><type>4096</type><stringId>G1</stringId></people>'),
                "group/g.xml": group_xml("PKG Administrators", "G1")}
            _, r = self._run(t, files)
            self.assertEqual(gates(r)["G03"], "PASS")
            self.assertTrue(findings(r, "PM-012"))

    def test_unresolvable_review(self):
        with tempfile.TemporaryDirectory() as t:
            _, r = self._run(t, {"processModel/p.xml": pm_xml()})
            self.assertEqual(gates(r)["G03"], "REVIEW")

    def test_only_users_fail(self):
        with tempfile.TemporaryDirectory() as t:
            _, r = self._run(t, {"processModel/p.xml": pm_xml(
                people='<people><type>4</type><stringId>user1</stringId></people>')})
            self.assertEqual(gates(r)["G03"], "FAIL")


class TestUserTasks(unittest.TestCase):
    def _task(self, extra=""):
        return (f'<node uuid="n2"><ac><local-id>internal.17</local-id>'
                f'<name>User Input Task</name></ac>'
                f'<assignments><assignee><type>5</type>'
                f'<value><string>u1</string></value></assignee></assignments>'
                f'{extra}</node>')

    def test_no_exception_fail(self):
        with tempfile.TemporaryDirectory() as t:
            node = self._task('<escalations/><deadline><enabled>false</enabled>'
                              '<type>0</type><units>0</units></deadline>')
            _, r = run({"processModel/p.xml": pm_xml(nodes=node)}, t)
            self.assertEqual(gates(r)["G07"], "FAIL")

    def test_deadline_one_day_pass(self):
        with tempfile.TemporaryDirectory() as t:
            node = self._task('<deadline><enabled>true</enabled><type>1</type>'
                              '<units>24</units></deadline><escalations/>')
            _, r = run({"processModel/p.xml": pm_xml(nodes=node)}, t)
            self.assertEqual(gates(r)["G07"], "PASS")

    def test_escalations_unreadable_review(self):
        with tempfile.TemporaryDirectory() as t:
            node = self._task('<escalations><escalation><foo>bar</foo>'
                              '</escalation></escalations>'
                              '<deadline><enabled>false</enabled><type>0</type>'
                              '<units>0</units></deadline>')
            _, r = run({"processModel/p.xml": pm_xml(nodes=node)}, t)
            self.assertEqual(gates(r)["G07"], "REVIEW")

    def test_start_form_not_task(self):
        with tempfile.TemporaryDirectory() as t:
            node = ('<node uuid="n1"><ac><local-id>core.0</local-id>'
                    '<name>Start Node</name><form-map><pair><form-config>'
                    '<form><type>3</type></form></form-config></pair>'
                    '</form-map></ac><pre-triggers/><escalations/>'
                    '<deadline><enabled>false</enabled><type>0</type>'
                    '<units>0</units></deadline></node>')
            _, r = run({"processModel/p.xml": pm_xml(nodes=node)}, t)
            self.assertEqual(gates(r)["G07"], "NA")


class TestRecordSync(unittest.TestCase):
    def _run(self, tmp, **kw):
        return run({"recordType/r.xml": record_xml("PKG Rec", **kw)}, tmp)

    def test_daily_fail(self):
        with tempfile.TemporaryDirectory() as t:
            v = '{"hour":3,"minute":"00","amPM":"AM","timeZone":"Europe/Madrid","dayOfWeek":""}'
            _, r = run({"recordType/r.xml": record_xml(
                "PKG Rec", replica=True, activated="true", value=v)}, t)
            self.assertEqual(gates(r)["G08"], "FAIL")

    def test_weekly_pass(self):
        with tempfile.TemporaryDirectory() as t:
            v = '{"hour":3,"minute":"00","amPM":"AM","timeZone":"Europe/Madrid","dayOfWeek":"6"}'
            _, r = run({"recordType/r.xml": record_xml(
                "PKG Rec", replica=True, activated="true", value=v)}, t)
            self.assertEqual(gates(r)["G08"], "PASS")
            self.assertTrue(findings(r, "REC-001"))

    def test_inactive_pass(self):
        with tempfile.TemporaryDirectory() as t:
            _, r = run({"recordType/r.xml": record_xml(
                "PKG Rec", replica=True, activated="false")}, t)
            self.assertEqual(gates(r)["G08"], "PASS")

    def test_not_synced_na(self):
        with tempfile.TemporaryDirectory() as t:
            _, r = run({"recordType/r.xml": record_xml("PKG Rec", replica=False)}, t)
            self.assertEqual(gates(r)["G08"], "NA")


class TestConstantsSecurity(unittest.TestCase):
    def test_password_value_sec004(self):
        with tempfile.TemporaryDirectory() as t:
            _, r = run({"content/c.xml": constant_xml(
                "PKG_API_SECRET", "P@ssw0rd123!")}, t)
            self.assertTrue(findings(r, "SEC-004"))
            self.assertEqual(findings(r, "SEC-006"), [])
            self.assertEqual(gates(r)["G09"], "FAIL")

    def test_slug_value_sec006(self):
        with tempfile.TemporaryDirectory() as t:
            _, r = run({"content/c.xml": constant_xml(
                "PKG_API_SECRET", "esp-appiantest-obj-archetype-config")}, t)
            self.assertEqual(findings(r, "SEC-004"), [])
            sec6 = findings(r, "SEC-006")
            self.assertTrue(sec6)
            self.assertEqual(sec6[0]["severity"], "MEDIUM")
            self.assertEqual(gates(r)["G09"], "PASS")


HC_CSV_HEADER = "ID,Category,Description,Risk,Details\n"


def hc_csv(rows):
    return HC_CSV_HEADER + "\n".join(rows) + "\n"


class TestHealthCheck(unittest.TestCase):
    def test_missing(self):
        with tempfile.TemporaryDirectory() as t:
            _, r = run({"content/r.xml": rule_xml("PKG_R1")}, t)
            self.assertEqual(gates(r)["G02"], "REVIEW")
            self.assertEqual(r["healthCheck"]["status"], "MISSING")

    def test_unreadable_error(self):
        with tempfile.TemporaryDirectory() as t:
            zip_path = make_zip({"content/r.xml": rule_xml("PKG_R1")}, t)
            code = A.main([zip_path, "-o", os.path.join(t, "o.json"),
                           "--health-check", os.path.join(t, "no.csv"),
                           "--gate", "--quiet"])
            self.assertEqual(code, 2)

    def test_empty_csv(self):
        with tempfile.TemporaryDirectory() as t:
            hc = os.path.join(t, "hc.csv")
            open(hc, "w").write(HC_CSV_HEADER)
            _, r = run({"content/r.xml": rule_xml("PKG_R1")}, t,
                       extra_args=["--health-check", hc])
            self.assertEqual(r["healthCheck"]["status"], "EMPTY")
            self.assertEqual(gates(r)["G02"], "REVIEW")

    def test_high_by_uuid(self):
        with tempfile.TemporaryDirectory() as t:
            hc = os.path.join(t, "hc.csv")
            open(hc, "w").write(hc_csv(["7,CAT,objeto PKG_RULEX riesgoso,High,x"]))
            _, r = run({"content/r.xml": rule_xml("PKG_RULEX")}, t,
                       extra_args=["--health-check", hc])
            self.assertEqual(gates(r)["G02"], "FAIL")
            ms = r["healthCheck"]["matchStats"]
            self.assertEqual(ms["byName"], 1)

    def test_platform_risk_pass(self):
        with tempfile.TemporaryDirectory() as t:
            hc = os.path.join(t, "hc.csv")
            open(hc, "w").write(hc_csv(["9,CAT,memoria de plataforma,High,x"]))
            _, r = run({"content/r.xml": rule_xml("PKG_R1")}, t,
                       extra_args=["--health-check", hc])
            self.assertEqual(gates(r)["G02"], "PASS")
            self.assertTrue(findings(r, "HC-003"))
            self.assertEqual(r["healthCheck"]["matchStats"]["unmatched"], 1)

    def test_stale_review(self):
        with tempfile.TemporaryDirectory() as t:
            old = (datetime.now() - timedelta(days=30)).strftime("%Y-%m-%d")
            hc = os.path.join(t, f"hc_{old}.csv")
            open(hc, "w").write(hc_csv(["1,CAT,algo,Medium,x"]))
            _, r = run({"content/r.xml": rule_xml("PKG_R1")}, t,
                       extra_args=["--health-check", hc])
            self.assertTrue(r["healthCheck"]["stale"])
            self.assertEqual(gates(r)["G02"], "REVIEW")


class TestCoverage(unittest.TestCase):
    def test_low_coverage_error(self):
        with tempfile.TemporaryDirectory() as t:
            files = {
                "content/a.xml": rule_xml("PKG_A", uuid="U1"),
                "content/b.xml": rule_xml("PKG_B", uuid="U2"),
                "META-INF/export.log": export_log(
                    [("PKG_A", "U1"), ("PKG_B", "U2"), ("PKG_C", "U3")]),
            }
            code, r = run(files, t)
            self.assertAlmostEqual(r["analysis"]["coverage"]["ratio"], 2 / 3, 2)
            self.assertEqual(r["deploymentGate"]["verdict"], "ERROR")
            self.assertEqual(code, 2)

    def test_low_min_coverage_ok(self):
        with tempfile.TemporaryDirectory() as t:
            files = {
                "content/a.xml": rule_xml("PKG_A", uuid="U1"),
                "content/b.xml": rule_xml("PKG_B", uuid="U2"),
                "META-INF/export.log": export_log(
                    [("PKG_A", "U1"), ("PKG_B", "U2"), ("PKG_C", "U3")]),
            }
            code, r = run(files, t, extra_args=["--min-coverage", "0.5"])
            self.assertNotEqual(r["deploymentGate"]["verdict"], "ERROR")


class TestJustifications(unittest.TestCase):
    def _zip(self, t):
        return make_zip({"processModel/p.xml": pm_xml(cleanup="1", delete_delay="3")}, t)

    def test_object_scoped(self):
        with tempfile.TemporaryDirectory() as t:
            z = self._zip(t)
            j = os.path.join(t, "j.json")
            json.dump({"PM-008:PKG Proceso": "aprobado OT"}, open(j, "w"))
            _, r = run({}, t) if False else (None, None)
            out = os.path.join(t, "o.json")
            A.main([z, "-o", out, "--justifications", j, "--quiet"])
            r = json.load(open(out))
            self.assertEqual(gates(r)["G04"], "JUSTIFIED")

    def test_generic_ignored_by_default(self):
        with tempfile.TemporaryDirectory() as t:
            z = self._zip(t)
            j = os.path.join(t, "j.json")
            json.dump({"PM-008": "gen"}, open(j, "w"))
            out = os.path.join(t, "o.json")
            A.main([z, "-o", out, "--justifications", j, "--quiet"])
            r = json.load(open(out))
            self.assertEqual(gates(r)["G04"], "FAIL")
            self.assertTrue(r["justifications"]["ignored"])

    def test_generic_applied_with_config(self):
        with tempfile.TemporaryDirectory() as t:
            z = self._zip(t)
            j = os.path.join(t, "j.json")
            c = os.path.join(t, "c.json")
            json.dump({"PM-008": "gen"}, open(j, "w"))
            json.dump({"allowGenericJustifications": True}, open(c, "w"))
            out = os.path.join(t, "o.json")
            A.main([z, "-o", out, "--justifications", j, "--config", c, "--quiet"])
            r = json.load(open(out))
            self.assertEqual(gates(r)["G04"], "JUSTIFIED")

    def test_gate_justification(self):
        with tempfile.TemporaryDirectory() as t:
            z = self._zip(t)
            j = os.path.join(t, "j.json")
            json.dump({"G04": {"text": "ok", "approver": "OT", "date": "2025-01-01"}},
                      open(j, "w"))
            out = os.path.join(t, "o.json")
            code = A.main([z, "-o", out, "--justifications", j, "--gate", "--quiet"])
            r = json.load(open(out))
            self.assertEqual(gates(r)["G04"], "JUSTIFIED")
            self.assertEqual(r["deploymentGate"]["verdict"], "APTO_CON_CONDICIONES")
            self.assertEqual(code, 3)


class TestDependencies(unittest.TestCase):
    def test_package_review(self):
        with tempfile.TemporaryDirectory() as t:
            _, r = run({"content/r.xml": rule_xml("PKG_R1")}, t)
            self.assertTrue(any(f["gateStatus"] == "REVIEW"
                                for f in findings(r, "DEPN-002")))
            self.assertFalse(findings(r, "DEPN-001"))

    def test_application_orphan_fail(self):
        with tempfile.TemporaryDirectory() as t:
            files = {
                "application/app.xml": ('<?xml version="1.0"?><applicationHaul>'
                                        '<application><name>PKG App</name>'
                                        '<uuid>APP1</uuid></application>'
                                        '</applicationHaul>'),
                "content/r.xml": rule_xml("PKG_R1"),
            }
            _, r = run(files, t)
            self.assertTrue(any(f["gateStatus"] == "FAIL"
                                for f in findings(r, "DEPN-001")))

    def test_record_type_root(self):
        with tempfile.TemporaryDirectory() as t:
            files = {
                "application/app.xml": ('<?xml version="1.0"?><applicationHaul>'
                                        '<application><name>PKG App</name>'
                                        '<uuid>APP1</uuid></application>'
                                        '</applicationHaul>'),
                "recordType/r.xml": record_xml("PKG Rec", replica=False),
            }
            _, r = run(files, t)
            self.assertFalse(findings(r, "DEPN-001"))


class TestExitCodes(unittest.TestCase):
    def test_apto_condiciones_3_noapto_1(self):
        with tempfile.TemporaryDirectory() as t:
            z = make_zip({"processModel/p.xml": pm_xml(cleanup="1", delete_delay="3")}, t)
            code = A.main([z, "-o", os.path.join(t, "o.json"),
                           "--gate", "--quiet"])
            self.assertEqual(code, 1)

    def test_evil_zip_error(self):
        with tempfile.TemporaryDirectory() as t:
            z = os.path.join(t, "evil.zip")
            with zipfile.ZipFile(z, "w") as zf:
                zf.writestr("../evil.xml", "<x/>")
                zf.writestr("content/r.xml", rule_xml("PKG_R1"))
            code = A.main([z, "-o", os.path.join(t, "o.json"),
                           "--gate", "--quiet"])
            self.assertEqual(code, 2)


class TestRealFixtures(unittest.TestCase):
    def _analyze(self, name):
        out = os.path.join(tempfile.mkdtemp(), f"{name}.json")
        code = A.main([os.path.join(FIXTURES, f"{name}.zip"), "-o", out,
                       "--gate", "--quiet"])
        return code, json.load(open(out))

    @unittest.skipUnless(os.path.exists(os.path.join(FIXTURES, "smk.zip")),
                         "fixture ausente")
    def test_smk(self):
        code, r = self._analyze("smk")
        g = gates(r)
        self.assertEqual(g["G04"], "PASS")
        self.assertEqual(g["G07"], "NA")
        self.assertEqual(g["G10"], "NA")
        self.assertEqual(g["G03"], "PASS")
        self.assertTrue(findings(r, "PM-012"))
        self.assertEqual(r["analysis"]["coverage"]["ratio"], 1.0)
        self.assertEqual(r["inventory"]["expectedObjects"], 143)
        self.assertEqual(code, 3)

    @unittest.skipUnless(os.path.exists(os.path.join(FIXTURES, "adm.zip")),
                         "fixture ausente")
    def test_adm(self):
        code, r = self._analyze("adm")
        g = gates(r)
        self.assertEqual(r["deploymentGate"]["verdict"], "NO_APTO")
        self.assertEqual(code, 1)
        self.assertEqual(g["G04"], "FAIL")
        pm008 = {f["objectName"] for f in findings(r, "PM-008")
                 if f["gateStatus"] == "FAIL"}
        self.assertEqual(pm008, {
            "ADM_PM_UNARCH_FindArchivedProcess", "ADM Recepcion Aprobacion RT",
            "ADM Close Version", "ADM Proceso Devops", "ADM TEST reactivar user",
            "ADM Modificar Correos Informes Usuarios", "ADM Registrar Despliegue"})
        self.assertEqual(g["G09"], "PASS")
        self.assertTrue(findings(r, "SEC-006"))
        # Los dos batch a las 05:00Z quedan en REVIEW por el cambio de hora
        self.assertEqual(g["G10"], "REVIEW")
        pm011_rev = {f["objectName"] for f in findings(r, "PM-011")
                     if f["gateStatus"] == "REVIEW"}
        self.assertEqual(len(pm011_rev), 2)


if __name__ == "__main__":
    unittest.main()
