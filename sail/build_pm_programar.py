import json

P = "7e501b5f-6715-46e2-976a-092858c8bdc8"
E = "e0fef5cc-80d6-491b-b74b-71d623d7a0ec"
PF = {
    "id": "798cdcc5-071f-4872-9997-5a17b1a6124a",
    "fechaProgramada": "abf0f0a4-17fa-4de6-8aeb-b5c85e35b646",
    "estado": "56e7aa5c-8bfe-494e-ba68-de5e1828388f",
    "modo": "c6ba445d-a508-4c70-a626-e6c4a7e804be",
    "codigos": "9ed6819f-a42d-4c2c-9461-d076d57fc391",
    "categorias": "a0cf551c-172f-4e01-b09f-3246bb70169f",
    "sistemas": "c43f5b47-1255-4001-9247-1c632350ec97",
    "numPruebas": "3fab4644-0a96-437a-8f1b-48744d5da6d4",
    "motivo": "90095155-8d17-46d8-9cba-95f6be4c0beb",
    "origen": "89356b5f-9992-4548-8d58-82f8d924574a",
    "creadoPor": "1202dd4f-496d-4462-a54f-ec133ff6d940",
    "fechaCreacion": "d866a44f-0e71-4260-9fcf-50c537fed215",
    "procesoId": "fdeeb26b-143e-46eb-8452-08ea35205331",
    "ejecucionId": "9b2af594-6312-4940-933a-6bdc464217ef",
    "fechaLanzamiento": "9432966e-1991-4fe3-b49e-9e159f39cfaf",
}
EF = {
    "id": "4a743dda-a9e3-46c9-8bc3-2826f9586ce1",
    "fechaInicio": "1e84e153-8cd3-492b-9b7f-3c97575a75e5",
    "estado": "4215f124-b13e-4aab-a280-50ebcff87ab8",
    "origen": "1a5bd16b-1600-4449-9b6c-acf1abb1a5af",
    "motivo": "a16d9b3a-c4b3-40d7-a11c-60bf0fc2a8d6",
    "lanzadoPor": "541ebf63-f4c4-4892-a696-265d622c55fc",
}

def pf(f): return f"'recordType!{{{P}}}SMK Programacion.fields.{{{PF[f]}}}{f}'"
def ef(f): return f"'recordType!{{{E}}}SMK Ejecucion.fields.{{{EF[f]}}}{f}'"
def prog(f): return f"pv!prog[{pf(f)}]"
def lista(f):
    return f"if(a!isNullOrEmpty({prog(f)}), null, trim(split({prog(f)}, \",\")))"

def conn(t, chained=False, label=None):
    c = {"targetNodeId": t, "activityChained": chained, "overridesAssignment": False, "synchronizeData": False}
    if label: c["label"] = label
    return c

def write_records(expr, save=None):
    return {
        "inputs": [
            {"name": "Records", "type": "Any Type", "expression": expr},
            {"name": "PauseOnError", "type": "Boolean", "value": 1},
            {"name": "RecordType", "type": "RecordType", "value": ""},
            {"name": "CaptureEvents", "type": "Boolean", "value": 0},
        ],
        "customInputs": [],
        "outputs": [
            {"name": "RecordsUpdated", "type": "Any Type", **({"saveInto": save} if save else {})},
            {"name": "ErrorOccurred", "type": "Boolean"},
            {"name": "Error", "type": "Text"},
        ],
        "customOutputs": [],
    }

def script(outs):
    return {"inputs": [], "customInputs": [], "outputs": [],
            "customOutputs": [{"expression": e, "saveInto": s} for e, s in outs]}

UNATT = {"attended": False, "runAs": "INITIATOR", "overrideLane": False}

crear_ejec = ("={" + f"'recordType!{{{E}}}SMK Ejecucion'(" +
    f"{ef('fechaInicio')}: now(), {ef('estado')}: \"EN_CURSO\", "
    f"{ef('origen')}: a!defaultValue({prog('origen')}, \"PROGRAMADO\"), "
    f"{ef('motivo')}: left(a!defaultValue({prog('motivo')}, \"\") & \" [Programación #\" & pv!programacionId & \" para \" & text({prog('fechaProgramada')}, \"dd/mm/yyyy hh:mm\") & \"]\", 4000), "
    f"{ef('lanzadoPor')}: a!defaultValue({prog('creadoPor')}, user(pp!initiator, \"username\")))" + "}")

marcar_lanzada = ("={" + f"'recordType!{{{P}}}SMK Programacion'(" +
    f"{pf('id')}: pv!programacionId, {pf('estado')}: \"LANZADA\", "
    f"{pf('ejecucionId')}: pv!ejecucionId, {pf('fechaLanzamiento')}: now(), {pf('procesoId')}: pp!id)" + "}")

crear_prog = ("={" + f"'recordType!{{{P}}}SMK Programacion'(" +
    f"{pf('fechaProgramada')}: pv!fechaProgramada, {pf('estado')}: \"PENDIENTE\", "
    f"{pf('modo')}: a!defaultValue(pv!modo, \"Todas\"), {pf('codigos')}: pv!codigosTxt, "
    f"{pf('categorias')}: pv!categoriasTxt, {pf('sistemas')}: pv!sistemasTxt, "
    f"{pf('numPruebas')}: pv!numPruebas, {pf('motivo')}: pv!motivo, "
    f"{pf('origen')}: a!defaultValue(pv!origen, \"PROGRAMADO\"), "
    f"{pf('creadoPor')}: a!defaultValue(pv!creadoPor, user(pp!initiator, \"username\")), "
    f"{pf('fechaCreacion')}: now(), {pf('procesoId')}: pp!id)" + "}")

nodes = [
    {"id": 1, "type": "core.0", "name": {"es": "Start"}, "coordinates": [56, 196], "connections": [conn(11, chained=True)]},
    {"id": 11, "type": "internal3.write_records_to_source_23r3", "name": {"es": "Registrar programación"}, "coordinates": [180, 196],
     "connections": [conn(12, chained=True)], "data": write_records(crear_prog, "progNueva"), "assignment": UNATT},
    {"id": 12, "type": "internal.16", "name": {"es": "Guardar id programación"}, "coordinates": [320, 196],
     "connections": [conn(3, chained=True)],
     "data": script([(f"index(pv!progNueva[1], {pf('id')}, null)", "programacionId")]), "assignment": UNATT},
    {"id": 3, "type": "event.timer", "name": {"es": "Esperar fecha programada"}, "coordinates": [460, 196],
     "connections": [conn(4)],
     "data": {"inputs": [{"name": "delayUntil", "type": "Text", "expression": "pv!fechaProgramada"}],
              "customInputs": [], "outputs": [], "customOutputs": []}},
    {"id": 4, "type": "internal.16", "name": {"es": "Leer programación"}, "coordinates": [600, 196],
     "connections": [conn(5)],
     "data": script([
         ("index(rule!SMK_getProgramaciones(id: pv!programacionId, estados: null, batchSize: null), 1, null)", "prog"),
     ]), "assignment": UNATT},
    {"id": 10, "type": "internal.16", "name": {"es": "Desglosar alcance"}, "coordinates": [740, 196],
     "connections": [conn(5)],
     "data": script([
         (f"a!defaultValue({prog('estado')}, \"DESCONOCIDO\")", "estado"),
         (lista("codigos"), "codigos"),
         (lista("categorias"), "categorias"),
         (lista("sistemas"), "sistemas"),
     ]), "assignment": UNATT},
    {"id": 5, "type": "core.4", "name": {"es": "¿Sigue pendiente?"}, "coordinates": [880, 196],
     "connections": [conn(6, label="Sí"), conn(2, label="No (cancelada)")],
     "decision": {"conditions": [{"expression": "pv!estado = \"PENDIENTE\"", "targetNodeId": 6, "label": "Sí"}],
                  "defaultPath": 2}},
    {"id": 6, "type": "internal3.write_records_to_source_23r3", "name": {"es": "Crear ejecución"}, "coordinates": [1020, 196],
     "connections": [conn(7)], "data": write_records(crear_ejec, "ejecucion"), "assignment": UNATT},
    {"id": 7, "type": "internal.16", "name": {"es": "Guardar id ejecución"}, "coordinates": [1160, 196],
     "connections": [conn(8)],
     "data": script([(f"index(pv!ejecucion[1], {ef('id')}, null)", "ejecucionId")]), "assignment": UNATT},
    {"id": 8, "type": "internal3.write_records_to_source_23r3", "name": {"es": "Marcar programación lanzada"}, "coordinates": [1300, 196],
     "connections": [conn(9)], "data": write_records(marcar_lanzada), "assignment": UNATT},
    {"id": 9, "type": "internal.38", "name": {"es": "Ejecutar pruebas"}, "coordinates": [1440, 196],
     "connections": [conn(2)],
     "data": {"inputs": [
         {"name": "Instructions", "type": "Text", "value": ""},
         {"name": "ejecucionId", "type": "Text", "expression": "pv!ejecucionId"},
         {"name": "codigos", "type": "Text", "expression": "pv!codigos"},
         {"name": "categorias", "type": "Text", "expression": "pv!categorias"},
         {"name": "sistemas", "type": "Text", "expression": "pv!sistemas"},
         {"name": "motivo", "type": "Text", "expression": f"left(a!defaultValue({prog('motivo')}, \"\") & \" [Programación #\" & pv!programacionId & \"]\", 4000)"},
         {"name": "origen", "type": "Text", "expression": f"a!defaultValue({prog('origen')}, \"PROGRAMADO\")"},
         {"name": "lanzadoPor", "type": "Text", "expression": f"a!defaultValue({prog('creadoPor')}, user(pp!initiator, \"username\"))"},
         {"name": "pmUUID", "type": "Text", "value": "0000f068-c618-8000-64a1-7f0000014e7a"},
         {"name": "isAsynchronous", "type": "Boolean", "value": 1},
         {"name": "isTransparent", "type": "Boolean", "value": 0},
         {"name": "inheritSecurity", "type": "Boolean", "value": 1},
         {"name": "chainsInto", "type": "Boolean", "value": 0},
     ], "customInputs": [],
        "outputs": [{"name": "subProcessID", "type": "Number (Integer)", "saveInto": "runnerProcesoId"},
                    {"name": "procInheritsPriority", "type": "Number (Integer)"}],
        "customOutputs": []},
     "assignment": UNATT},
    {"id": 2, "type": "core.1", "name": {"es": "End"}, "coordinates": [1590, 196], "connections": []},
]
# fix: node 4 -> 10 -> 5
next(n for n in nodes if n["id"]==4)["connections"] = [conn(10)]

pvs = [
    {"name": "fechaProgramada", "type": "Date and Time", "isParameter": True, "isRequired": True, "multiple": False},
    {"name": "modo", "type": "Text", "isParameter": True, "isRequired": False, "multiple": False},
    {"name": "codigosTxt", "type": "Text", "isParameter": True, "isRequired": False, "multiple": False},
    {"name": "categoriasTxt", "type": "Text", "isParameter": True, "isRequired": False, "multiple": False},
    {"name": "sistemasTxt", "type": "Text", "isParameter": True, "isRequired": False, "multiple": False},
    {"name": "numPruebas", "type": "Number (Integer)", "isParameter": True, "isRequired": False, "multiple": False},
    {"name": "motivo", "type": "Text", "isParameter": True, "isRequired": False, "multiple": False},
    {"name": "origen", "type": "Text", "isParameter": True, "isRequired": False, "multiple": False},
    {"name": "creadoPor", "type": "Text", "isParameter": True, "isRequired": False, "multiple": False},
    {"name": "programacionId", "type": "Number (Integer)", "isParameter": False, "isRequired": False, "multiple": False},
    {"name": "progNueva", "type": f"{{urn:com:appian:recordtype:datatype}}{P}", "isParameter": False, "isRequired": False, "multiple": True},
    {"name": "prog", "type": f"{{urn:com:appian:recordtype:datatype}}{P}", "isParameter": False, "isRequired": False, "multiple": False},
    {"name": "estado", "type": "Text", "isParameter": False, "isRequired": False, "multiple": False},
    {"name": "codigos", "type": "Text", "isParameter": False, "isRequired": False, "multiple": True},
    {"name": "categorias", "type": "Text", "isParameter": False, "isRequired": False, "multiple": True},
    {"name": "sistemas", "type": "Text", "isParameter": False, "isRequired": False, "multiple": True},
    {"name": "ejecucion", "type": f"{{urn:com:appian:recordtype:datatype}}{E}", "isParameter": False, "isRequired": False, "multiple": True},
    {"name": "ejecucionId", "type": "Number (Integer)", "isParameter": False, "isRequired": False, "multiple": False},
    {"name": "runnerProcesoId", "type": "Number (Integer)", "isParameter": False, "isRequired": False, "multiple": False},
]

args = {"uuid": "0000f06e-01ed-8000-654b-7f0000014e7a", "processVariables": pvs, "nodes": nodes}
json.dump(args, open("/home/ubuntu/smoke/pm_programar_args.json", "w"), ensure_ascii=False, indent=1)
print("ok")
