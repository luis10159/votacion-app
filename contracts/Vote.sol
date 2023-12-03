// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract SistemaVotacion {

  // Estructuras

  struct Votante {
    string nombre;
    uint256 dni;
    bool haVotado;
    uint256 facultadId; // Nueva variable para almacenar el ID de la facultad
  }

  struct Candidato {
    uint256 idPartido;
    uint256 cantidadVotos;
    bool principal;
  }

  struct Eleccion {
    string nombre;
    uint256 anio;
    uint256[] candidatos;
    uint256 ganador;
  }

  struct Partido {
    string nombre;
  }

  struct Facultad {
    string nombre;
  }

  // Arreglos
  Votante[] public votantes;
  Candidato[] public candidatos;
  Partido[] public partidos;
  Eleccion[] public elecciones;
  Facultad[] public facultades;

  // Mapeos
  mapping(address => Votante) public mapaVotantes; // Mapeo de direcciones a votantes
  mapping(uint256 => uint256) public candidatosIndex; // Mapeo de ID de candidatos a índices de candidatos
  mapping(uint256 => uint256) public partidosIndex; // Mapeo de ID de partidos a índices de partidos
  mapping(uint256 => uint256) public eleccionesIndex; // Mapeo de ID de elecciones a índices de elecciones
  mapping(string => uint256) public facultadesIndex; // Mapeo de nombres de facultades a índices de facultades

  // Variables públicas

  bool public votacionAbierta;
  address public owner; // Declarar la variable owner

  // Modifiers
  modifier onlyOwner() {
    require(msg.sender == owner, "Solo el propietario puede ejecutar esta funcion.");
    _;
  }
  modifier noHaVotado() {
    require(!mapaVotantes[msg.sender].haVotado, "El votante ya ha votado.");
    _;
  }

  modifier soloVotacionAbierta() {
    require(votacionAbierta, "La votacion esta cerrada.");
    _;
  }

  modifier soloVotacionCerrada() {
    require(!votacionAbierta, "La votacion esta abierta.");
    _;
  }

  // Constructor

  constructor() {
    owner = msg.sender;
  }

  // --- Funciones

  // Registrar votante con facultad
  function registrarVotante(string memory nombre, uint256 dni, string memory facultad) public onlyOwner {
    require(facultadesIndex[facultad] != 0, "La facultad no existe."); // Asegurar que la facultad exista
    Votante memory nuevoVotante = Votante(nombre, dni, false, facultadesIndex[facultad]);
    mapaVotantes[msg.sender] = nuevoVotante;
  }

  // Agregar nueva facultad
  function agregarFacultad(string memory nombre) public onlyOwner {
    require(facultadesIndex[nombre] == 0, "La facultad ya existe."); // Asegurar que la facultad no exista
    Facultad memory nuevaFacultad = Facultad(nombre);
    facultades.push(nuevaFacultad);
    facultadesIndex[nombre] = facultades.length;
  }

  // Obtener todas las facultades
  function obtenerFacultades() public view returns (Facultad[] memory) {
    return facultades;
  }

  function agregarCandidato(uint256 idPartido, bool principal) public onlyOwner {
    Candidato memory candidato = Candidato(idPartido, 0, principal);
    candidatos.push(candidato);
  }

  function agregarPartido(string memory nombre) public onlyOwner {
    Partido memory partido = Partido(nombre);
    partidos.push(partido);
  }

  // Crear elección

  function crearEleccion(uint256 idEleccion, string memory nombre, uint256 anio, uint256[] memory idsCandidatos) public onlyOwner {
    elecciones[idEleccion] = Eleccion(nombre, anio, idsCandidatos, 0);
  }

  // Emitir voto

  function emitirVoto(uint256 /* idEleccion */, uint256 idCandidato) public soloVotacionAbierta noHaVotado {
    candidatos[idCandidato].cantidadVotos++;
    mapaVotantes[msg.sender].haVotado = true;
  }

  // Determinar ganador

  function determinarGanador(uint256 idEleccion) public view soloVotacionCerrada returns (uint256) {
    require(elecciones[idEleccion].anio != 0, "La eleccion no existe.");
    return candidatos[elecciones[idEleccion].candidatos[0]].idPartido;
  }

  // Cantidad de partidos
  function obtenerCantidadPartidos() public view returns (uint256) {
    return partidos.length;
  }

  // --- Obtener información
  // Obtener el número de votos de un candidato específico
  function obtenerNumeroVotosCandidato(uint256 idCandidato) public view returns (uint256) {
    require(idCandidato < candidatos.length, "Candidato no encontrado.");
    return candidatos[idCandidato].cantidadVotos;
  }

  // Información de un candidato específico
  function obtenerInformacionCandidato(uint256 idCandidato) public view returns (uint256 idPartido, uint256 cantidadVotos, bool principal) {
    require(idCandidato < candidatos.length, "Candidato no encontrado.");
    Candidato memory candidato = candidatos[idCandidato];
    return (candidato.idPartido, candidato.cantidadVotos, candidato.principal);
  }

  // Obtener la lista de todos los partidos
  function obtenerPartidos() public view returns (Partido[] memory) {
    return partidos;
  }

  // Votantes
  function obtenerVotantes() public view returns (Votante[] memory) {
    Votante[] memory listaVotantes = new Votante[](1);
    listaVotantes[0] = mapaVotantes[msg.sender];
    return listaVotantes;
  }

  // Obtener elecciones
  function obtenerElecciones() public view returns (Eleccion[] memory) {
    Eleccion[] memory listaElecciones = new Eleccion[](1);
    listaElecciones[0] = elecciones[1]; // Puedes cambiar esto según tus necesidades
    return listaElecciones;
  }

  // Candidatos
  function obtenerCandidatos() public view returns (Candidato[] memory) {
    return candidatos;
  }

  // Ganador
  function ganador(uint256 idEleccion) public view returns (uint256) {
    require(elecciones[idEleccion].anio != 0, "La eleccion no existe.");
    return elecciones[idEleccion].ganador;
  }
}
