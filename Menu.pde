// =====================================================================
// 4. MENÚ PRINCIPAL Y PANTALLA "CÓMO JUGAR"
// =====================================================================

// Botón rectangular que cambia de color al pasar el ratón
class BotonMenu {
  float x, y, w, h;
  String texto;

  BotonMenu(float x, float y, float w, float h, String texto) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.texto = texto;
  }

  boolean encima() {
    float mx = mouseX * ANCHO / (float) width;    // el ratón, pasado a coordenadas del juego
    float my = mouseY * ALTO / (float) height;
    return mx > x && mx < x + w && my > y && my < y + h;
  }

  void dibujar() {
    if (encima()) fill(255, 160, 60);
    else fill(200, 90, 40);
    stroke(255);
    strokeWeight(2);
    rect(x, y, w, h, 10);
    noStroke();
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(20);
    text(texto, x + w / 2, y + h / 2);
  }
}

// Botones de todas las pantallas
BotonMenu btnJugar, btnJugarRed, btnSeleccion, btnAyuda, btnSalir, btnVolver;
BotonMenu btnDificultad, btnCambiarModo, btnRedDificultad;
BotonMenu btnPausaHUD, btnReanudar, btnReiniciarNivel, btnPausaMenu;
BotonMenu btnSiguiente, btnRepetir, btnVictoriaMenu;
BotonMenu btnCrear, btnUnirse, btnRedJugar, btnRedElegir, btnDesconectar;
BotonMenu[] botonesNivel = new BotonMenu[TOTAL_NIVELES];

void crearBotones() {
  // Menú principal
  btnJugar     = new BotonMenu(330, 310, 300, 45, "Jugar");
  btnJugarRed  = new BotonMenu(330, 365, 300, 45, "Jugar en red");
  btnSeleccion = new BotonMenu(330, 420, 300, 45, "Seleccionar nivel");
  btnAyuda     = new BotonMenu(330, 475, 300, 45, "Cómo jugar");
  btnSalir     = new BotonMenu(380, 580, 200, 40, "Salir del juego");
  btnVolver    = new BotonMenu(380, 575, 200, 45, "Volver");
  btnDificultad = new BotonMenu(330, 530, 300, 45, "Modo dificultad");

  // Selección de niveles: dos columnas de cinco
  for (int i = 0; i < TOTAL_NIVELES; i++) {
    botonesNivel[i] = new BotonMenu(90 + (i / 5) * 400, 120 + (i % 5) * 80, 380, 60, "");
  }
  btnCambiarModo = new BotonMenu(330, 515, 300, 45, "Ver modo dificultad");

  // Partida, pausa y victoria
  btnPausaHUD       = new BotonMenu(880, 2, 75, 28, "Pausa");
  btnReanudar       = new BotonMenu(360, 230, 240, 50, "Reanudar");
  btnReiniciarNivel = new BotonMenu(360, 295, 240, 50, "Reiniciar nivel");
  btnPausaMenu      = new BotonMenu(360, 360, 240, 50, "");
  btnSiguiente      = new BotonMenu(360, 360, 240, 50, "Siguiente nivel");
  btnRepetir        = new BotonMenu(230, 425, 240, 50, "Repetir nivel");
  btnVictoriaMenu   = new BotonMenu(490, 425, 240, 50, "");

  // Juego en red (pestaña Red)
  btnCrear       = new BotonMenu(120, 300, 300, 50, "Crear partida");
  btnUnirse      = new BotonMenu(540, 360, 300, 50, "Unirse");
  btnRedJugar    = new BotonMenu(330, 300, 300, 50, "");
  btnRedElegir   = new BotonMenu(330, 365, 300, 50, "Elegir nivel");
  btnRedDificultad = new BotonMenu(330, 430, 300, 50, "Modo dificultad");
  btnDesconectar = new BotonMenu(380, 575, 200, 45, "Desconectar");
}

void dibujarMenu() {
  // el fondo generado incluye el título y los personajes; si falta el archivo, color liso
  if (fondoMenu != null) image(fondoMenu, 0, 0, ANCHO, ALTO);
  else background(40, 30, 70);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(18);
  text("Niveles completados: " + contarCompletados() + " / " + TOTAL_NIVELES, ANCHO / 2, 550);

  // el botón Jugar dice hasta dónde se ha llegado
  if (nivelDesbloqueado == 0) btnJugar.texto = "Jugar";
  else btnJugar.texto = "Continuar (nivel " + (nivelDesbloqueado + 1) + ")";

  btnDificultad.texto = textoBotonDificultad();

  btnJugar.dibujar();
  btnJugarRed.dibujar();
  btnSeleccion.dibujar();
  btnAyuda.dibujar();
  if (modoDificultadDesbloqueado()) btnDificultad.dibujar();
  btnSalir.dibujar();
}

void clickMenu() {
  if (btnJugar.encima()) {
    modoDificultad = false;
    cargarNivel(nivelDesbloqueado);
  }
  else if (modoDificultadDesbloqueado() && btnDificultad.encima()) iniciarModoDificultad();
  else if (btnJugarRed.encima()) {
    mensajeRed = "";
    estado = RED;
  }
  else if (btnSeleccion.encima()) {
    seleccionDificultad = false;
    estado = SELECCION;
  }
  else if (btnAyuda.encima()) estado = AYUDA;
  else if (btnSalir.encima()) salirDelJuego();
}

int contarCompletados() {
  int total = 0;
  for (int i = 0; i < TOTAL_NIVELES; i++) {
    if (nivelCompletado[i]) total++;
  }
  return total;
}

boolean modoDificultadDesbloqueado() {
  return contarCompletados() == TOTAL_NIVELES;
}

int contarCompletadosDificultad() {
  int total = 0;
  for (int i = 0; i < TOTAL_NIVELES; i++) {
    if (dificultadCompletado[i]) total++;
  }
  return total;
}

// El modo dificultad sigue desde el último nivel desbloqueado en ese modo
void iniciarModoDificultad() {
  modoDificultad = true;
  cargarNivel(dificultadDesbloqueado);
}

String textoBotonDificultad() {
  if (dificultadDesbloqueado == 0) return "Modo dificultad";
  return "Dificultad (nivel " + (dificultadDesbloqueado + 1) + ")";
}

String[] TEXTO_AYUDA = {
  "CONTROLES",
  "Fuego: A y D para moverse, W para saltar.",
  "Agua: flechas izquierda y derecha para moverse, flecha arriba para saltar.",
  "ESC o P: pausa.     R: reiniciar el nivel.",
  "",
  "REGLAS",
  "Fuego puede pisar la lava, pero muere en el agua.",
  "Agua puede pisar el agua, pero muere en la lava.",
  "El ácido verde y caer al vacío matan a los dos.",
  "Fuego recoge las gemas rojas y Agua las azules.",
  "Modo dificultad: todas las gemas y tiempo límite (20 s, 30 s o 45 s).",
  "Un botón abre las puertas de su color mientras alguien lo pisa.",
  "Las plataformas grises se mueven y llevan a quien esté encima.",
  "Cada personaje debe llegar a su puerta. Si uno muere, el nivel se reinicia.",
  "",
  "EN RED: uno crea la partida (Fuego) y el otro se une con su IP (Agua)."
};

void dibujarAyuda() {
  background(40, 30, 70);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(40);
  text("Cómo jugar", ANCHO / 2, 50);
  textSize(18);
  for (int i = 0; i < TEXTO_AYUDA.length; i++) {
    text(TEXTO_AYUDA[i], ANCHO / 2, 120 + i * 30);
  }
  btnVolver.dibujar();
}


// =====================================================================
// 5. SELECCIÓN DE NIVELES
// =====================================================================
void dibujarSeleccion() {
  background(40, 30, 70);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(40);
  if (!modoDificultadDesbloqueado()) seleccionDificultad = false;
  boolean dif = seleccionDificultad;
  int desbloqueado = dif ? dificultadDesbloqueado : nivelDesbloqueado;
  text(dif ? "Selecciona un nivel (dificultad)" : "Selecciona un nivel", ANCHO / 2, 60);

  for (int i = 0; i < TOTAL_NIVELES; i++) {
    BotonMenu b = botonesNivel[i];
    if (i <= desbloqueado) {
      b.texto = (i + 1) + ". " + NOMBRES_NIVELES[i];
      if (dif ? dificultadCompletado[i] : nivelCompletado[i]) b.texto += "  (completado)";
      b.dibujar();
    } else {
      // nivel bloqueado: gris y sin efecto al pasar el ratón
      fill(90);
      stroke(150);
      rect(b.x, b.y, b.w, b.h, 10);
      noStroke();
      fill(170);
      textSize(20);
      text((i + 1) + ". Bloqueado", b.x + b.w / 2, b.y + b.h / 2);
    }
  }
  // botón para cambiar entre los niveles normales y los de dificultad
  if (modoDificultadDesbloqueado()) {
    btnCambiarModo.texto = dif ? "Ver modo normal" : "Ver modo dificultad";
    btnCambiarModo.dibujar();
  }
  btnVolver.dibujar();
}

void clickSeleccion() {
  int desbloqueado = seleccionDificultad ? dificultadDesbloqueado : nivelDesbloqueado;
  for (int i = 0; i <= desbloqueado; i++) {
    if (botonesNivel[i].encima()) {
      modoDificultad = seleccionDificultad;
      cargarNivel(i);
      return;
    }
  }
  if (modoDificultadDesbloqueado() && btnCambiarModo.encima()) seleccionDificultad = !seleccionDificultad;
  else if (btnVolver.encima()) irAlMenu();
}
