// SPDX-FileCopyrightText: Copyright 2026 crueter
// SPDX-License-Identifier: LGPL-3.0-or-later

#include <opus.h>
#include <stdio.h>
#include <stdlib.h>

#define SAMPLE_RATE 48000
#define CHANNELS 2
#define MAX_FRAME_SIZE 5760

int main(void) {
  int error;
  OpusDecoder *decoder;

  // make decoder
  decoder = opus_decoder_create(SAMPLE_RATE, CHANNELS, &error);
  if (error != OPUS_OK || decoder == NULL) {
    fprintf(stderr, "Failed to create Opus decoder: %s\n",
            opus_strerror(error));
    return EXIT_FAILURE;
  }

  // very basic packet
  static const unsigned char hardcoded_packet[] = {
      0x78, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};

  const int packet_len = sizeof(hardcoded_packet);

  opus_int16 pcm[MAX_FRAME_SIZE * CHANNELS];

  // decode
  int frame_size = opus_decode(decoder, hardcoded_packet, packet_len, pcm,
                               MAX_FRAME_SIZE, 0);

  if (frame_size < 0) {
    fprintf(stderr, "Decoding failed: %s\n", opus_strerror(frame_size));
  } else {
    printf("Successfully decoded %d samples (%d ms)\n", frame_size,
           (frame_size * 1000) / SAMPLE_RATE);
  }

  // cleanup
  opus_decoder_destroy(decoder);

  return (frame_size < 0) ? EXIT_FAILURE : EXIT_SUCCESS;
}