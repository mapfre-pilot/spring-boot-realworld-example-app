package com.mapfre.mavisa.wss372vencimientosmanuales.pagebeans;

import mapfre.wss000arquitect.capalogica.datos.J000J000Usuario;

/**
 * @author everis
 * @version 1.0 Versión inicial Clase de negocio. Encapsula los datos del
 *          detalle del programa.
 * 
 */
public class J372J009ConsultaCarteraVenPageBean {

	/**
	 * Inicializacion de la variable ENBLANCO, valor BLANCO
	 */
	private static final String ENBLANCO = "";

	/**
	 * Inicializamos el poliza, con valor ENBLANCO
	 */
	private String poliza = ENBLANCO;

	/**
	 * Inicializamos el subpoliza, con valor ENBLANCO
	 */
	private String subpoliza = ENBLANCO;

	/**
	 * Inicializamos el certificado, con valor ENBLANCO
	 */
	private String certificado = ENBLANCO;

	/**
	 * Inicializamos el aniopol, con valor ENBLANCO
	 */
	private String aniopol = ENBLANCO;

	/**
	 * Inicializamos el retorno, con valor ENBLANCO
	 */
	private String retorno;

	/**
	 * Inicializamos el desRetorno, con valor ENBLANCO
	 */
	private String desRetorno;

	/**
	 * Inicializamos el usuario, con valor ENBLANCO
	 */
	private J000J000Usuario usuario;

	/**
	 * Inicializamos el nomPrograma, con valor ENBLANCO
	 */
	private String nomPrograma;

	/**
	 * Inicializamos el ramo, con valor ENBLANCO
	 */
	private String ramo = ENBLANCO;

	/**
	 * Inicializamos el polizaSalida, con valor ENBLANCO
	 */
	private String polizaSalida = ENBLANCO;

	/**
	 * Inicializamos el subPolizaSalida, con valor ENBLANCO
	 */
	private String subPolizaSalida = ENBLANCO;

	/**
	 * Inicializamos el situacion, con valor ENBLANCO
	 */
	private String situacion = ENBLANCO;

	/**
	 * Inicializamos el modalidad, con valor ENBLANCO
	 */
	private String modalidad = ENBLANCO;

	/**
	 * Inicializamos el fecEfecto, con valor ENBLANCO
	 */
	private String fecEfecto = ENBLANCO;

	/**
	 * Inicializamos el fecAnul, con valor ENBLANCO
	 */
	private String fecAnul = ENBLANCO;

	/**
	 * Inicializamos el regionalPol, con valor ENBLANCO
	 */
	private String regionalPol = ENBLANCO;

	/**
	 * Inicializamos el canalCamp, con valor ENBLANCO
	 */
	private String canalCamp = ENBLANCO;

	/**
	 * Inicializamos el oficina, con valor ENBLANCO
	 */
	private String oficina = ENBLANCO;

	/**
	 * Inicializamos el entidad, con valor ENBLANCO
	 */
	private String entidad = ENBLANCO;

	/**
	 * Inicializamos el tomador, con valor ENBLANCO
	 */
	private String tomador = ENBLANCO;

	/**
	 * Inicializamos el duracion, con valor ENBLANCO
	 */
	private String duracion = ENBLANCO;

	/**
	 * Inicializamos el nifCifPri, con valor ENBLANCO
	 */
	private String nifCifPri = ENBLANCO;

	/**
	 * Inicializamos el PolizaBloq3, con valor ENBLANCO
	 */
	private String PolizaBloq3 = ENBLANCO;

	/**
	 * @return el polizaBloq3
	 */
	public String getPolizaBloq3 () {
		return PolizaBloq3;
	}

	/**
	 * @param polizaBloq3
	 *            el polizaBloq3 a establecer
	 */
	public void setPolizaBloq3 ( String polizaBloq3 ) {
		PolizaBloq3 = polizaBloq3;
	}

	/**
	 * @return el aniopol
	 */
	public String getAniopol () {
		return aniopol;
	}

	/**
	 * @param aniopol
	 *            el aniopol a establecer
	 */
	public void setAniopol ( String aniopol ) {
		this.aniopol = aniopol;
	}

	/**
	 * @return el certificado
	 */
	public String getCertificado () {
		return certificado;
	}

	/**
	 * @param certificado
	 *            el certificado a establecer
	 */
	public void setCertificado ( String certificado ) {
		this.certificado = certificado;
	}

	/**
	 * @return el desRetorno
	 */
	public String getDesRetorno () {
		return desRetorno;
	}

	/**
	 * @param desRetorno
	 *            el desRetorno a establecer
	 */
	public void setDesRetorno ( String desRetorno ) {
		this.desRetorno = desRetorno;
	}

	/**
	 * @return el duracion
	 */
	public String getDuracion () {
		return duracion;
	}

	/**
	 * @param duracion
	 *            el duracion a establecer
	 */
	public void setDuracion ( String duracion ) {
		this.duracion = duracion;
	}

	/**
	 * @return el fecAnul
	 */
	public String getFecAnul () {
		return fecAnul;
	}

	/**
	 * @param fecAnul
	 *            el fecAnulacion a establecer
	 */
	public void setFecAnul ( String fecAnul ) {
		this.fecAnul = fecAnul;
	}

	/**
	 * @return el fecEfecto
	 */
	public String getFecEfecto () {
		return fecEfecto;
	}

	/**
	 * @param fecEfecto
	 *            el fecEfecto a establecer
	 */
	public void setFecEfecto ( String fecEfecto ) {
		this.fecEfecto = fecEfecto;
	}

	/**
	 * @return el modalidad
	 */
	public String getModalidad () {
		return modalidad;
	}

	/**
	 * @param modalidad
	 *            el modalidad a establecer
	 */
	public void setModalidad ( String modalidad ) {
		this.modalidad = modalidad;
	}

	/**
	 * @return el nomPrograma
	 */
	public String getNomPrograma () {
		return nomPrograma;
	}

	/**
	 * @param nomPrograma
	 *            el nomPrograma a establecer
	 */
	public void setNomPrograma ( String nomPrograma ) {
		this.nomPrograma = nomPrograma;
	}

	/**
	 * @return el oficina
	 */
	public String getOficina () {
		return oficina;
	}

	/**
	 * @param oficina
	 *            el oficina a establecer
	 */
	public void setOficina ( String oficina ) {
		this.oficina = oficina;
	}

	/**
	 * @return el poliza
	 */
	public String getPoliza () {
		return poliza;
	}

	/**
	 * @param poliza
	 *            el poliza a establecer
	 */
	public void setPoliza ( String poliza ) {
		this.poliza = poliza;
	}

	/**
	 * @return el polizaSalida
	 */
	public String getPolizaSalida () {
		return polizaSalida;
	}

	/**
	 * @param polizaSalida
	 *            el polizaSalida a establecer
	 */
	public void setPolizaSalida ( String polizaSalida ) {
		this.polizaSalida = polizaSalida;
	}

	/**
	 * @return el ramo
	 */
	public String getRamo () {
		return ramo;
	}

	/**
	 * @param ramo
	 *            el ramo a establecer
	 */
	public void setRamo ( String ramo ) {
		this.ramo = ramo;
	}

	/**
	 * @return el retorno
	 */
	public String getRetorno () {
		return retorno;
	}

	/**
	 * @param retorno
	 *            el retorno a establecer
	 */
	public void setRetorno ( String retorno ) {
		this.retorno = retorno;
	}

	/**
	 * @return el situacion
	 */
	public String getSituacion () {
		return situacion;
	}

	/**
	 * @param situacion
	 *            el situacion a establecer
	 */
	public void setSituacion ( String situacion ) {
		this.situacion = situacion;
	}

	/**
	 * @return el subpoliza
	 */
	public String getSubpoliza () {
		return subpoliza;
	}

	/**
	 * @param subpoliza
	 *            el subpoliza a establecer
	 */
	public void setSubpoliza ( String subpoliza ) {
		this.subpoliza = subpoliza;
	}

	/**
	 * @return el subPolizaSalida
	 */
	public String getSubPolizaSalida () {
		return subPolizaSalida;
	}

	/**
	 * @param subPolizaSalida
	 *            el subPolizaSalida a establecer
	 */
	public void setSubPolizaSalida ( String subPolizaSalida ) {
		this.subPolizaSalida = subPolizaSalida;
	}

	/**
	 * @return el tomador
	 */
	public String getTomador () {
		return tomador;
	}

	/**
	 * @param tomador
	 *            el tomador a establecer
	 */
	public void setTomador ( String tomador ) {
		this.tomador = tomador;
	}

	/**
	 * @return el usuario
	 */
	public J000J000Usuario getUsuario () {
		return usuario;
	}

	/**
	 * @param usuario
	 *            el usuario a establecer
	 */
	public void setUsuario ( J000J000Usuario usuario ) {
		this.usuario = usuario;
	}

	/**
	 * @return el nifCifPri
	 */
	public String getNifCifPri () {
		return nifCifPri;
	}

	/**
	 * @param nifCifPri
	 *            el nifCifPri a establecer
	 */
	public void setNifCifPri ( String nifCifPri ) {
		this.nifCifPri = nifCifPri;
	}

	/**
	 * @return el entidad
	 */
	public String getEntidad () {
		return entidad;
	}

	/**
	 * @param entidad
	 *            el entidad a establecer
	 */
	public void setEntidad ( String entidad ) {
		this.entidad = entidad;
	}

	/**
	 * @return el canalCamp
	 */
	public String getCanalCamp () {
		return canalCamp;
	}

	/**
	 * @param canalCamp
	 *            el canalCamp a establecer
	 */
	public void setCanalCamp ( String canalCamp ) {
		this.canalCamp = canalCamp;
	}

	/**
	 * @return el regionalPol
	 */
	public String getRegionalPol () {
		return regionalPol;
	}

	/**
	 * @param regionalPol
	 *            el regionalPol a establecer
	 */
	public void setRegionalPol ( String regionalPol ) {
		this.regionalPol = regionalPol;
	}

}
