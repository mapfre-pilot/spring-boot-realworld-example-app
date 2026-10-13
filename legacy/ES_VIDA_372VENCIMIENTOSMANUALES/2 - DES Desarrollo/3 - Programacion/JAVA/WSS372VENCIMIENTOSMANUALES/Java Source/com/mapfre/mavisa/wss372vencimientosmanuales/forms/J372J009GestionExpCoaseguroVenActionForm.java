package com.mapfre.mavisa.wss372vencimientosmanuales.forms;

import org.apache.struts.action.ActionForm;

import java.util.Collections;
import java.util.List;
import java.util.Vector;

// R&V Junio 2017 - CU011 - everis(RGL)
public class J372J009GestionExpCoaseguroVenActionForm extends ActionForm {

    private String tipOperacionJSP = "";
    private String desRetorno = "";
    private String retorno = "";
    private List<Object> vectorMensajes = Collections.synchronizedList (new Vector<Object>());

    private String polizaBloq3 = ""; //La poliza esta (en el formulario) en tres bloques Tramo|Año|#poliza
    private String subpoliza = "";

    private String codCoa1 = "";
    private String codCoa2 = "";
    private String codCoa3 = "";
    private String codCoa4 = "";
    private String codCoa5 = "";
    private String codCoa6 = "";
    private String porCoa1 = "0,0";
    private String porCoa2 = "0,0";
    private String porCoa3 = "0,0";
    private String porCoa4 = "0,0";
    private String porCoa5 = "0,0";
    private String porCoa6 = "0,0";

    public String getCodCoa1() {
        return codCoa1;
    }

    public void setCodCoa1(String codCoa1) {
        this.codCoa1 = codCoa1;
    }

    public String getCodCoa2() {
        return codCoa2;
    }

    public void setCodCoa2(String codCoa2) {
        this.codCoa2 = codCoa2;
    }

    public String getCodCoa3() {
        return codCoa3;
    }

    public void setCodCoa3(String codCoa3) {
        this.codCoa3 = codCoa3;
    }

    public String getCodCoa4() {
        return codCoa4;
    }

    public void setCodCoa4(String codCoa4) {
        this.codCoa4 = codCoa4;
    }

    public String getCodCoa5() {
        return codCoa5;
    }

    public void setCodCoa5(String codCoa5) {
        this.codCoa5 = codCoa5;
    }

    public String getCodCoa6() {
        return codCoa6;
    }

    public void setCodCoa6(String codCoa6) {
        this.codCoa6 = codCoa6;
    }

    public String getPorCoa1() {
        return porCoa1;
    }

    public void setPorCoa1(String porCoa1) {
        this.porCoa1 = porCoa1;
    }

    public String getPorCoa2() {
        return porCoa2;
    }

    public void setPorCoa2(String porCoa2) {
        this.porCoa2 = porCoa2;
    }

    public String getPorCoa3() {
        return porCoa3;
    }

    public void setPorCoa3(String porCoa3) {
        this.porCoa3 = porCoa3;
    }

    public String getPorCoa4() {
        return porCoa4;
    }

    public void setPorCoa4(String porCoa4) {
        this.porCoa4 = porCoa4;
    }

    public String getPorCoa5() {
        return porCoa5;
    }

    public void setPorCoa5(String porCoa5) {
        this.porCoa5 = porCoa5;
    }

    public String getPorCoa6() {
        return porCoa6;
    }

    public void setPorCoa6(String porCoa6) {
        this.porCoa6 = porCoa6;
    }

    public String getTipOperacionJSP() {
        return tipOperacionJSP;
    }

    public void setTipOperacionJSP(String tipOperacionJSP) {
        this.tipOperacionJSP = tipOperacionJSP;
    }

    public String getDesRetorno() {
        return desRetorno;
    }

    public void setDesRetorno(String desRetorno) {
        this.desRetorno = desRetorno;
    }

    public String getRetorno() {
        return retorno;
    }

    public void setRetorno(String retorno) {
        this.retorno = retorno;
    }

    public List<Object> getVectorMensajes() {
        return vectorMensajes;
    }

    public void setVectorMensajes(List<Object> vectorMensajes) {
        this.vectorMensajes = vectorMensajes;
    }

    public String getPolizaBloq3() {
        return polizaBloq3;
    }

    public void setPolizaBloq3(String polizaBloq3) {
        this.polizaBloq3 = polizaBloq3;
    }

    public String getSubpoliza() {
        return subpoliza;
    }

    public void setSubpoliza(String subpoliza) {
        this.subpoliza = subpoliza;
    }


}
