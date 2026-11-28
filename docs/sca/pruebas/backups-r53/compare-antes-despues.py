import json,sys,urllib.parse
sys.path.insert(0,'.')
from t import call
P=[("SCA_obtenerRolPerfilSubperfil","_a-0000eb9b-717e-8000-9c54-011c48011c48_12084835","SCA2_obtenerRolPerfilSubperfil","_a-0000f069-4f37-8000-9cc8-011c48011c48_20050948",[{"nuuma":"JJGONZ2"},{"nuuma":"SISANS"}]),
("SCA_consultarSolicitudes","_a-0000eb9b-717e-8000-9c54-011c48011c48_12076283","SCA2_consultarSolicitudes","_a-0000f069-4f37-8000-9cc8-011c48011c48_20050936",[{"numPoliza":"0730080003210","codInt":"","tpBusqueda":"0"}]),
("SCA_consultarCabeceraSolicitud","_a-0000eba7-4ece-8000-9c59-011c48011c48_12389367","SCA2_consultarCabeceraSolicitud","_a-0000f069-4f37-8000-9cc8-011c48011c48_20051080",[{"codSolicitud":"15788677"}])]
def run(u,i):
    d=call("POST",f"/expression-rules/{u}/test",{"inputs":i,"timeoutSeconds":60,"maxResponseSizeBytes":1000000})
    return d.get("result"),d.get("diagnostics",{}).get("error")
for a,ua,b,ub,ins in P:
    for i in ins:
        ra,ea=run(ua,i); rb,eb=run(ub,i)
        print(b,json.dumps(i,ensure_ascii=False),"IGUAL" if (ra==rb and ea==eb) else "DISTINTO", "| err:",str(ea)[:80],"/",str(eb)[:80], "| tam:",len(json.dumps(ra)))
