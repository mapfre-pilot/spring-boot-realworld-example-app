# Descubrimiento de novedades para SMK Pruebas de Humo.
# Se ejecuta desde Devin con scripted_tools (pegar el contenido inline). Solo usa operaciones MCP de lectura.
# Salida: discovery/snapshot_<env>.json (inventario) y discovery/hallazgos_<env>.md (nuevos / desaparecidos / cambiados)
import asyncio, json, os, re, datetime
from urllib.parse import urlparse
from devin_tools import tools

S = "appian-dev-mcp-desarrollo-05c9"   # servidor MCP del entorno a inventariar
ENV = "dev"
BASE = "/home/ubuntu/smoke"
CATALOGO_BASE_UUID = "_a-0000f069-4f37-8000-9cc8-011c48011c48_20037624"  # SMK_catalogoBase
DB_TYPES = ("DataSource",)
# New discovery catalog rows are created inactive and require manual review.
DISCOVERY_ORIGIN = "DESCUBRIMIENTO"
DISCOVERY_INACTIVE_REASON = "Detectada por descubrimiento automático el <fecha>; pendiente de revisión"

def norm_host(url):
    try:
        u = urlparse(url if "://" in url else "https://" + url)
        return (u.hostname or "").lower(), u.port
    except Exception:
        return "", None

def code_from_host(host, port):
    c = re.sub(r"[^A-Z0-9]", "_", host.upper())
    return f"HTTP_{c}" + (f"_{port}" if port else "")

async def mcp(tool, **args):
    r = await tools.mcp_call_tool(server=S, tool_name=tool, tool_args=json.dumps(args))
    if r.startswith("Error"):
        raise RuntimeError(f"{tool}: {r[:200]}")
    return json.loads(r)

async def list_all(tool, key=None, **args):
    out, off = [], 0
    while True:
        r = await mcp(tool, limit=200, offset=off, **args)
        items = r.get("items") or r.get(key or "") or (r if isinstance(r, list) else [])
        out += items
        if len(items) < 200:
            return out
        off += 200

async def main():
    os.makedirs(f"{BASE}/discovery", exist_ok=True)
    apps = await list_all("listApplications")
    cs_by_uuid = {}
    sem = asyncio.Semaphore(8)
    async def cs_for(a):
        async with sem:
            return a, await list_all("listConnectedSystems", appUuid=a["uuid"])
    for a, lst in await asyncio.gather(*[cs_for(a) for a in apps]):
        for c in lst:
            cs_by_uuid.setdefault(c["uuid"], dict(c, apps=[]))["apps"].append(a["name"])
    # detalle (baseUrl) para HTTP
    async def detail(u, c):
        async with sem:
            try:
                d = await mcp("getConnectedSystem", uuid=u)
                c["baseUrl"] = (d.get("properties") or {}).get("baseUrl")
                c["authType"] = (d.get("properties") or {}).get("authType")
            except Exception as e:
                c["error"] = str(e)[:120]
    await asyncio.gather(*[detail(u, c) for u, c in cs_by_uuid.items() if c["type"].startswith("system.http")])
    # record types por CS de BD (para saber si hay algo consultable read-only)
    async def rt_for(a):
        async with sem:
            return await list_all("listRecordTypes", appUuid=a["uuid"])
    rts = [r for lst in await asyncio.gather(*[rt_for(a) for a in apps]) for r in lst]
    rt_by_ds = {}
    for r in rts:
        ds = r.get("dataSourceUuid")
        if ds:
            rt_by_ds.setdefault(ds, []).append(r["name"])

    # catálogo base actual
    cat = await mcp("getExpressionRule", uuid=CATALOGO_BASE_UUID)
    expr = cat.get("expression", "")
    codigos = set(re.findall(r'codigo:\s*"([^"]+)"', expr))
    sistemas = set(s.lower() for s in re.findall(r'sistema:\s*"([^"]+)"', expr))
    expr_lc = expr.lower()  # un CS está cubierto si su nombre aparece en el catálogo base (nombre/descripcion/sistema)

    snapshot = {"env": ENV, "fecha": datetime.datetime.utcnow().isoformat(), "connectedSystems": cs_by_uuid,
                "recordTypesPorDataSource": rt_by_ds, "catalogoCodigos": sorted(codigos)}
    prev_path = f"{BASE}/discovery/snapshot_{ENV}.json"
    prev = json.load(open(prev_path)) if os.path.exists(prev_path) else None

    nuevos, sin_cobertura = [], []
    for u, c in cs_by_uuid.items():
        t = c["type"]
        if t.startswith("system.http"):
            host, port = norm_host(c.get("baseUrl") or "")
            if not host:
                continue
            codigo = code_from_host(host, port)
            cubierto = codigo in codigos or any(k.startswith(codigo) for k in codigos) or host in sistemas or c["name"].lower() in expr_lc
            if not cubierto:
                sin_cobertura.append(dict(tipo="HTTP", cs=c["name"], uuid=u, host=host, port=port, auth=c.get("authType"),
                                          apps=c["apps"], propuesta=f"Integración GET ligera vía CS '{c['name']}' → código {codigo}"))
        elif any(k in t for k in DB_TYPES):
            cubierto = c["name"].lower() in expr_lc
            if not cubierto:
                rtn = rt_by_ds.get(u, [])
                sin_cobertura.append(dict(tipo="DB", cs=c["name"], uuid=u, apps=c["apps"], recordTypes=rtn[:5],
                                          propuesta=(f"Consulta read-only batchSize 1 sobre record type '{rtn[0]}'" if rtn
                                                     else "Sin record types dependientes: no hay consulta read-only posible sin crear objetos")))
        elif t.startswith("plugin.") and c["name"].lower() not in expr_lc:
            sin_cobertura.append(dict(tipo="PLUGIN", cs=c["name"], uuid=u, apps=c["apps"], plugin=t,
                                      propuesta="Revisar manualmente: operación de lectura del plugin"))
        if prev and u not in prev["connectedSystems"]:
            nuevos.append(dict(cs=c["name"], tipo=t, apps=c["apps"]))
    desaparecidos = [dict(cs=v["name"], tipo=v["type"]) for u, v in (prev or {}).get("connectedSystems", {}).items() if u not in cs_by_uuid]
    cambiados = []
    if prev:
        for u, c in cs_by_uuid.items():
            p = prev["connectedSystems"].get(u)
            if p and c.get("baseUrl") != p.get("baseUrl"):
                cambiados.append(dict(cs=c["name"], antes=p.get("baseUrl"), ahora=c.get("baseUrl")))

    json.dump(snapshot, open(prev_path, "w"), indent=1, ensure_ascii=False)
    md = [f"# Hallazgos SMK — {ENV} — {snapshot['fecha'][:16]}Z", "",
          f"Connected Systems: {len(cs_by_uuid)} · Record types: {len(rts)} · Pruebas en catálogo base: {len(codigos)}", "",
          f"## Nuevos desde el último snapshot ({len(nuevos)})"] + [f"- {n['cs']} ({n['tipo']}) — apps: {', '.join(n['apps'])}" for n in nuevos] + \
         ["", f"## Desaparecidos ({len(desaparecidos)})"] + [f"- {d['cs']} ({d['tipo']})" for d in desaparecidos] + \
         ["", f"## URL cambiada ({len(cambiados)})"] + [f"- {c['cs']}: {c['antes']} → {c['ahora']}" for c in cambiados] + \
         ["", f"## Sin prueba de humo en el catálogo ({len(sin_cobertura)})"] + \
         [f"- [{s['tipo']}] {s['cs']} — apps: {', '.join(s['apps'])} — {s['propuesta']}" for s in sin_cobertura]
    open(f"{BASE}/discovery/hallazgos_{ENV}.md", "w").write("\n".join(md))
    json.dump(dict(nuevos=nuevos, desaparecidos=desaparecidos, cambiados=cambiados, sinCobertura=sin_cobertura),
              open(f"{BASE}/discovery/hallazgos_{ENV}.json", "w"), indent=1, ensure_ascii=False)
    print("\n".join(md[:6])); print(f"sin cobertura: {len(sin_cobertura)} (HTTP {sum(1 for s in sin_cobertura if s['tipo']=='HTTP')}, DB {sum(1 for s in sin_cobertura if s['tipo']=='DB')}, PLUGIN {sum(1 for s in sin_cobertura if s['tipo']=='PLUGIN')})")

asyncio.run(main())
