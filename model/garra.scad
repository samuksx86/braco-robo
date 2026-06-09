/* ============================================================
 *  GARRA DO BRAÇO ROBÓTICO - COLETA DE AMOSTRAS ESPACIAIS
 *  Modelo paramétrico em OpenSCAD
 *  Projetada para servo 9g (SG90) - encaixe previsto no corpo
 * ============================================================
 *  Ajuste as variáveis abaixo para redimensionar a peça.
 * ============================================================ */

// ----------------- PARÂMETROS AJUSTÁVEIS -----------------
comprimento_dedo   = 50;   // Comprimento de cada dedo da garra (mm)
largura_dedo       = 8;    // Largura do dedo (mm)
espessura          = 5;    // Espessura geral das peças (mm)
abertura_garra     = 40;   // Distância entre os dedos quando aberta (mm)
num_dentes         = 5;    // Dentes de fixação na ponta (microgravidade)
tam_dente          = 3;    // Tamanho de cada dente (mm)

// Encaixe do servo SG90 (9g) - dimensões padrão
servo_larg  = 23.2;  // Largura do corpo do servo (mm)
servo_prof  = 12.5;  // Profundidade do corpo (mm)
servo_alt   = 12;    // Altura do rebaixo de encaixe (mm)
furo_eixo   = 5;     // Diâmetro do furo para o eixo do servo (mm)

base_larg  = abertura_garra + 2*largura_dedo + 20; // Largura da base
base_prof  = 30;                                   // Profundidade da base

$fn = 48; // Resolução das curvas

// ----------------- MONTAGEM -----------------
base_garra();
dedo(posicao = -abertura_garra/2 - largura_dedo, espelhar = false);
dedo(posicao =  abertura_garra/2,                espelhar = true);

// ----------------- MÓDULOS -----------------

// Base da garra com rebaixo para o servo 9g e furo do eixo
module base_garra() {
    difference() {
        // Corpo da base com cantos arredondados
        hull() {
            for (x = [-base_larg/2 + 4, base_larg/2 - 4])
                for (y = [4, base_prof - 4])
                    translate([x, y, 0])
                        cylinder(h = espessura + servo_alt, r = 4);
        }
        // Rebaixo de encaixe do servo SG90
        translate([-servo_larg/2, base_prof/2 - servo_prof/2, espessura])
            cube([servo_larg, servo_prof, servo_alt + 1]);
        // Furo para passagem do eixo/braço do servo
        translate([0, base_prof/2, -1])
            cylinder(h = espessura + 2, d = furo_eixo);
        // Furos dos parafusos de fixação do servo (M2)
        for (x = [-servo_larg/2 - 2.5, servo_larg/2 + 2.5])
            translate([x, base_prof/2, -1])
                cylinder(h = espessura + servo_alt + 2, d = 2.2);
    }
}

// Dedo da garra com dentes de retenção (evita fuga da amostra
// em microgravidade, onde a carga "flutua" se mal presa).
// O dedo é desenhado com a face interna em x = 0 e os dentes
// apontando para o centro da garra; depois é espelhado conforme o lado.
module dedo(posicao, espelhar) {
    translate([posicao + (espelhar ? 0 : largura_dedo), base_prof - 2, 0])
        mirror([espelhar ? 0 : 1, 0, 0])
            union() {
                // Haste do dedo (face interna alinhada em x = 0)
                cube([largura_dedo, comprimento_dedo, espessura]);
                // Dentes de retenção na face interna, voltados ao centro
                for (i = [0 : num_dentes - 1])
                    translate([0,
                               comprimento_dedo*0.35
                               + i*(comprimento_dedo*0.55/num_dentes),
                               0])
                        dente();
                // Ponta curva de captura (gancho interno)
                translate([0, comprimento_dedo, 0])
                    linear_extrude(height = espessura)
                        polygon([[0, 0],
                                 [-largura_dedo*0.8, largura_dedo*0.6],
                                 [0, largura_dedo*1.2],
                                 [largura_dedo*0.5, 0]]);
            }
}

// Dente triangular de retenção (aponta para -X, centro da garra)
module dente() {
    linear_extrude(height = espessura)
        polygon([[0, 0], [-tam_dente, tam_dente/2], [0, tam_dente]]);
}
