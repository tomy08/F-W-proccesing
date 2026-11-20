// =====================================================================
// 11. INTERFAZ, PAUSA Y PANTALLAS DE VICTORIA
// =====================================================================

// Marcador de arriba: nivel, gemas, tiempo y botón de pausa
void dibujarHUD() {
  noStroke();
  fill(0, 150);
  rect(0, 0, ANCHO, 32);
  fill(255);
  textAlign(LEFT, CENTER);
  textSize(16);
  String etiquetaNivel = modoDificultad ? "Dificultad " : "Nivel ";
  text(etiquetaNivel + (nivelActual + 1) + ": " + NOMBRES_NIVELES[nivelActual], 10, 15);
  text("Gemas rojas: " + gemasRojas + "/" + totalRojas + "    Azules: " + gemasAzules + "/" + totalAzules, 330, 15);
  if (modoDificultad) {
    int segundosRestantes = max(0, (tiempoDificultad() - framesNivel) / 60);
    text("Tiempo: " + segundosRestantes / 60 + ":" + nf(segundosRestantes % 60, 2), 700, 15);
  } else {
    text("Tiempo: " + framesNivel / 60 + " s", 700, 15);
  }
  btnPausaHUD.dibujar();
  if (modoDificultad && !todasLasGemasRecogidas()) {
    fill(255, 210, 60);
    textAlign(CENTER, TOP);
    textSize(16);
    text("DIFICULTAD: recoge todas las gemas antes de salir", ANCHO / 2, 38);
  }
}

void dibujarMensajeMuerte() {
  fill(0, 150);
  rect(0, ALTO / 2 - 40, ANCHO, 80);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(30);
  text(mensajeMuerte, ANCHO / 2, ALTO / 2);
}

// Oscurece el juego y escribe un título (para la pausa y la victoria)
void dibujarPanel(String titulo) {
  fill(0, 170);
  noStroke();
  rect(0, 0, ANCHO, ALTO);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(40);
  text(titulo, ANCHO / 2, 160);
}

// En red, "Menú principal" lleva a la sala de red o sale de la partida
String textoBotonSalir() {
  if (modoRed == ANFITRION) return "Sala de red";
  if (modoRed == INVITADO) return "Salir de la partida";
  return "Menú principal";
}


// ---------------------------------------------------------------------
// Pausa
// ---------------------------------------------------------------------
void pausar() {
  estado = PAUSA;
  soltarTeclas();
}

void dibujarPausa() {
  dibujarPanel("PAUSA");
  btnPausaMenu.texto = textoBotonSalir();
  btnPausaMenu.dibujar();
  if (modoRed == INVITADO) {
    text("El anfitrión ha pausado la partida", ANCHO / 2, 260);   // el invitado solo puede salir
  } else {
    btnReanudar.dibujar();
    btnReiniciarNivel.dibujar();
  }
}

void clickPausa() {
  if (btnPausaMenu.encima()) {
    if (modoRed == INVITADO) desconectar();
    else irAlMenu();
  } else if (modoRed != INVITADO && btnReanudar.encima()) estado = JUGANDO;
  else if (modoRed != INVITADO && btnReiniciarNivel.encima()) reiniciarNivel();
}


// ---------------------------------------------------------------------
// Fin de nivel (y fin del juego al superar el nivel 10)
// ---------------------------------------------------------------------
void completarNivel() {
  registrarNivelCompletado();
  reproducir(sonidoVictoria);
  soltarTeclas();
  estado = VICTORIA;
}

// Marca el nivel actual como superado (en el modo que se esté jugando),
// desbloquea el siguiente y lo guarda en progreso.txt
void registrarNivelCompletado() {
  boolean haySiguiente = nivelActual + 1 < TOTAL_NIVELES;
  if (modoDificultad) {
    dificultadCompletado[nivelActual] = true;
    if (haySiguiente && dificultadDesbloqueado < nivelActual + 1) dificultadDesbloqueado = nivelActual + 1;
  } else {
    nivelCompletado[nivelActual] = true;
    if (haySiguiente && nivelDesbloqueado < nivelActual + 1) nivelDesbloqueado = nivelActual + 1;
  }
  guardarProgreso();
}

boolean esUltimoNivel() {
  return nivelActual == TOTAL_NIVELES - 1;
}

void siguienteNivel() {
  if (!esUltimoNivel()) cargarNivel(nivelActual + 1);
}

void dibujarVictoria() {
  if (esUltimoNivel()) {
    // victoria final: se han superado los 10 niveles
    dibujarPanel("¡VICTORIA!");
    textSize(26);
    if (modoDificultad) text("¡Han superado el modo dificultad!", ANCHO / 2, 220);
    else text("Fuego y Agua han conquistado el Templo de la 35", ANCHO / 2, 220);
    textSize(18);
    if (modoDificultad) text("Todas las gemas y el límite de tiempo fueron obligatorios", ANCHO / 2, 260);
    else text("Has completado los 10 niveles de Fireboy & Watergirl: La 35° Aventura", ANCHO / 2, 260);
  } else {
    dibujarPanel("¡Nivel " + (nivelActual + 1) + " superado!");
    textSize(22);
    text("Pulsa ENTER para continuar", ANCHO / 2, 260);
  }
  text("Gemas rojas: " + gemasRojas + "/" + totalRojas + "    Gemas azules: " + gemasAzules + "/" + totalAzules
    + "    Tiempo: " + framesNivel / 60 + " s", ANCHO / 2, 310);

  btnVictoriaMenu.texto = textoBotonSalir();
  btnVictoriaMenu.dibujar();
  if (modoRed == INVITADO) {
    text("El anfitrión elige cómo seguir", ANCHO / 2, 380);
  } else {
    if (!esUltimoNivel()) btnSiguiente.dibujar();
    btnRepetir.dibujar();
  }
}

void clickVictoria() {
  if (btnVictoriaMenu.encima()) {
    if (modoRed == INVITADO) desconectar();
    else irAlMenu();
  } else if (modoRed != INVITADO && btnSiguiente.encima()) siguienteNivel();
  else if (modoRed != INVITADO && btnRepetir.encima()) reiniciarNivel();
}
