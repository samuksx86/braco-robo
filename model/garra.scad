/* ============================================================
 *  GARRA DO BRAÇO ROBÓTICO - COLETA DE AMOSTRAS ESPACIAIS
 *  Modelo paramétrico em OpenSCAD — 3 PEÇAS SEPARADAS:
 *
 *   1. BASE        : suporte com encaixe para o servo 9g (SG90)
 *   2. DEDO MOTOR  : acoplado ao eixo do servo (com engrenagem)
 *   3. DEDO LIVRE  : gira em parafuso M3, movido pela engrenagem
 *
 *  Os dois dedos possuem setores de engrenagem que se engrenam:
 *  quando o servo gira o dedo motor, o dedo livre se move em
 *  espelho, abrindo e fechando a garra simetricamente.
 * ============================================================ */

// ----------------- MODO DE VISUALIZAÇÃO -----------------
modo_montado = false; // true  = visualização da garra montada
                      // false = peças separadas p/ impressão (USAR P/ EXPORTAR STL)

// ----------------- PARÂMETROS AJUSTÁVEIS -----------------
comprimento_dedo = 45;   // Comprimento do dedo após o pivô (mm)
largura_dedo     = 8;    // Largura da haste do dedo (mm)
espessura        = 5;    // Espessura das peças (mm)
raio_engrenagem  = 11;   // Raio do setor de engrenagem (mm)
num_dentes_eng   = 8;    // Dentes do setor de engrenagem
num_dentes_grip  = 4;    // Dentes de retenção na ponta do dedo
tam_dente_grip   = 2.5;  // Tamanho do dente de retenção (mm)
angulo_abertura  = 12;   // Ângulo de abertura na visualização (graus)

// Encaixe do servo SG90 (9g)
servo_larg   = 23.2;  // Largura do corpo (mm)
servo_prof   = 12.5;  // Profundidade do corpo (mm)
servo_alt    = 16;    // Altura do rebaixo de encaixe (mm)
furo_eixo    = 4.8;   // Furo para a engrenagem do eixo (spline)
furo_m3      = 3.2;   // Furo para parafuso M3 (pivô do dedo livre)
furo_m2      = 2.2;   // Furos dos parafusos de fixação do servo

dist_pivos = 2 * raio_engrenagem; // Distância entre os 2 pivôs
$fn = 64;

// ===================== MONTAGEM =====================
if (modo_montado) {
    // ---- Visualização montada (não usar para imprimir) ----
    color("SteelBlue")  base();
    color("Orange")
        translate([-dist_pivos/2, 0, espessura + 1])
            rotate([0, 0,  angulo_abertura]) dedo(motor = true);
    color("Gold")
        translate([ dist_pivos/2, 0, espessura + 1])
            rotate([0, 0, -angulo_abertura]) mirror([1,0,0]) dedo(motor = false);
} else {
    // ---- Peças separadas, deitadas para impressão 3D ----
    base();
    translate([-dist_pivos - 30, 25, 0]) dedo(motor = true);
    translate([ dist_pivos + 30, 25, 0]) mirror([1,0,0]) dedo(motor = false);
}

// ===================== MÓDULOS =====================

/* PEÇA 1 — BASE
 * Placa com rebaixo para o servo SG90, furo do eixo (pivô do
 * dedo motor) e furo M3 (pivô do dedo livre). */
module base() {
    base_larg = dist_pivos + 2*raio_engrenagem + 16;
    base_prof = servo_prof + 16;
    difference() {
        // Corpo com cantos arredondados
        hull()
            for (x = [-base_larg/2 + 5, base_larg/2 - 5])
                for (y = [-base_prof/2 + 5, base_prof/2 - 5])
                    translate([x, y, 0]) cylinder(h = espessura, r = 5);

        // Furo do eixo do servo (pivô do dedo motor)
        translate([-dist_pivos/2, 0, -1])
            cylinder(h = espessura + 2, d = furo_eixo + 2);
        // Furo M3 (pivô do dedo livre)
        translate([ dist_pivos/2, 0, -1])
            cylinder(h = espessura + 2, d = furo_m3);
        // Furos M2 de fixação do servo
        for (x = [-dist_pivos/2 - servo_larg/2 - 2.5,
                  -dist_pivos/2 + servo_larg/2 + 2.5])
            translate([x, 0, -1])
                cylinder(h = espessura + 2, d = furo_m2);
    }
    // Caixa de encaixe do servo, presa sob a base
    translate([-dist_pivos/2, 0, 0]) suporte_servo();
}

/* Paredes que abraçam o corpo do servo SG90 por baixo da base */
module suporte_servo() {
    parede = 2.5;
    translate([0, 0, -servo_alt])
        difference() {
            translate([-servo_larg/2 - parede, -servo_prof/2 - parede, 0])
                cube([servo_larg + 2*parede, servo_prof + 2*parede, servo_alt]);
            translate([-servo_larg/2, -servo_prof/2, -1])
                cube([servo_larg, servo_prof, servo_alt + 2]);
        }
}

/* PEÇAS 2 e 3 — DEDOS
 * motor = true  : furo spline p/ eixo do servo (4,8 mm)
 * motor = false : furo liso p/ parafuso M3 (gira livre)
 * Cada dedo tem um setor de engrenagem no pivô; os setores dos
 * dois dedos se engrenam, sincronizando abertura/fechamento. */
module dedo(motor) {
    difference() {
        union() {
            setor_engrenagem();
            // Haste do dedo partindo do pivô
            translate([-largura_dedo/2, raio_engrenagem - 2, 0])
                cube([largura_dedo, comprimento_dedo, espessura]);
            // Dentes de retenção (face interna) — microgravidade:
            // impedem que a amostra escape flutuando
            for (i = [0 : num_dentes_grip - 1])
                translate([-largura_dedo/2,
                           raio_engrenagem + comprimento_dedo*0.45
                           + i*(comprimento_dedo*0.45/num_dentes_grip), 0])
                    dente_grip();
            // Gancho de captura na ponta
            translate([-largura_dedo/2, raio_engrenagem - 2 + comprimento_dedo, 0])
                linear_extrude(height = espessura)
                    polygon([[0, 0], [largura_dedo, 0],
                             [largura_dedo, 3],
                             [-4, 8], [-1, 0]]);
        }
        // Furo do pivô
        translate([0, 0, -1])
            cylinder(h = espessura + 2,
                     d = motor ? furo_eixo : furo_m3);
        // Rebaixo p/ cabeça do parafuso do horn (apenas dedo motor)
        if (motor)
            translate([0, 0, espessura - 2])
                cylinder(h = espessura, d = 7);
    }
}

/* Setor de engrenagem (~120°) centrado no pivô do dedo */
module setor_engrenagem() {
    // Disco do setor
    cylinder(h = espessura, r = raio_engrenagem - 1);
    // Dentes distribuídos no arco voltado ao outro dedo
    for (i = [0 : num_dentes_eng - 1])
        rotate([0, 0, -150 + i * (120 / (num_dentes_eng - 1))])
            translate([raio_engrenagem - 1.6, -1.2, 0])
                linear_extrude(height = espessura)
                    polygon([[0, -1.2], [2.4, 0], [0, 1.2]]);
}

/* Dente triangular de retenção, apontando p/ dentro da garra */
module dente_grip() {
    linear_extrude(height = espessura)
        polygon([[0, 0],
                 [-tam_dente_grip, tam_dente_grip/2],
                 [0, tam_dente_grip]]);
}
