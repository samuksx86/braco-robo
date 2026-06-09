/*
 * ============================================================
 *  BRAÇO ROBÓTICO DE COLETA DE AMOSTRAS (Docking & Retrieval)
 *  Manipulação de carga em ambiente de microgravidade
 * ============================================================
 *  Placa     : Arduino Uno
 *  Atuadores : 2x Servomotores 9g (SG90)
 *              - Servo 1: Articulação do braço (elevação)
 *              - Servo 2: Garra (abrir/fechar)
 *  Indicador : LED de status (pisca ao executar comandos)
 *  Fonte     : Fonte de bancada 5V (alimentação dos servos)
 *
 *  COMANDOS VIA MONITOR SERIAL (9600 baud):
 *    U -> Up    : sobe o braço
 *    D -> Down  : desce o braço
 *    O -> Open  : abre a garra
 *    C -> Close : fecha a garra (captura a amostra)
 * ============================================================
 */

#include <Servo.h>

// ---------- Pinagem ----------
const int PINO_SERVO_BRACO = 9;   // Servo da articulação (PWM)
const int PINO_SERVO_GARRA = 10;  // Servo da garra (PWM)
const int PINO_LED_STATUS  = 13;  // LED de status

// ---------- Ângulos de operação ----------
const int BRACO_CIMA   = 150;  // Posição elevada do braço
const int BRACO_BAIXO  = 30;   // Posição abaixada (aproximação da amostra)
const int GARRA_ABERTA = 90;   // Garra totalmente aberta
const int GARRA_FECHADA = 10;  // Garra fechada (segurando a amostra)

// ---------- Objetos servo ----------
Servo servoBraco;
Servo servoGarra;

void setup() {
  Serial.begin(9600);                 // Inicia comunicação serial

  servoBraco.attach(PINO_SERVO_BRACO);
  servoGarra.attach(PINO_SERVO_GARRA);
  pinMode(PINO_LED_STATUS, OUTPUT);

  // Posição inicial segura: braço elevado e garra aberta
  servoBraco.write(BRACO_CIMA);
  servoGarra.write(GARRA_ABERTA);

  digitalWrite(PINO_LED_STATUS, HIGH); // LED aceso = sistema pronto

  Serial.println(F("=== BRACO ROBOTICO - DOCKING & RETRIEVAL ==="));
  Serial.println(F("Sistema iniciado. Comandos disponiveis:"));
  Serial.println(F("  U -> Subir braco"));
  Serial.println(F("  D -> Descer braco"));
  Serial.println(F("  O -> Abrir garra"));
  Serial.println(F("  C -> Fechar garra (capturar amostra)"));
}

void loop() {
  // Verifica se há comando disponível no Monitor Serial
  if (Serial.available() > 0) {
    char comando = toupper(Serial.read()); // Aceita maiúsculas e minúsculas

    switch (comando) {
      case 'U':
        executarComando("Subindo braco...", servoBraco, BRACO_CIMA);
        break;

      case 'D':
        executarComando("Descendo braco...", servoBraco, BRACO_BAIXO);
        break;

      case 'O':
        executarComando("Abrindo garra...", servoGarra, GARRA_ABERTA);
        break;

      case 'C':
        executarComando("Fechando garra - amostra capturada!", servoGarra, GARRA_FECHADA);
        break;

      case '\n': // Ignora quebras de linha enviadas pelo Monitor Serial
      case '\r':
        break;

      default:
        Serial.print(F("Comando invalido: "));
        Serial.println(comando);
        Serial.println(F("Use: U, D, O ou C"));
        break;
    }
  }
}

/*
 * Move o servo indicado para o ângulo desejado de forma suave
 * (movimento gradual evita "trancos" na carga em microgravidade)
 * e pisca o LED de status durante a execução.
 */
void executarComando(const char* mensagem, Servo &servo, int anguloFinal) {
  Serial.println(mensagem);
  digitalWrite(PINO_LED_STATUS, LOW); // LED apaga: comando em execução

  int anguloAtual = servo.read();
  int passo = (anguloFinal > anguloAtual) ? 1 : -1;

  // Movimento suave, grau a grau
  for (int a = anguloAtual; a != anguloFinal; a += passo) {
    servo.write(a);
    delay(15); // Controla a velocidade do movimento
  }
  servo.write(anguloFinal);

  digitalWrite(PINO_LED_STATUS, HIGH); // LED acende: comando concluído
  Serial.println(F("OK - movimento concluido."));
}
