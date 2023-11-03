// Copyright 2020 OpenHW Group
// Copyright 2023 Dolphin Design
//
// Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://solderpad.org/licenses/
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier:Apache-2.0 WITH SHL-2.0
//
// Description : Higlights unecessary Register File multiple writes
//

#include <stdio.h>

#define MSTATUS_FS_INITIAL 0x00002000
#define MSTATUS_FS_CLEAN 0x00004000

#ifdef FPU
void fp_enable ()
{
  unsigned int fs = MSTATUS_FS_INITIAL;
  __asm__ volatile("csrs mstatus, %0;"
                   "csrwi fcsr, 0;"
                   : : "r"(fs));
}
#endif

int main()
{
  int error = 0;

  long int a, b;
  long long int mul64;
  float f_res;

  volatile float *f_p = 0x2008;

  // MULH
  a = 0x12345678;
  b = 0x98765432;

#ifdef FPU
  // Floating Point enable
  unsigned int f_s = MSTATUS_FS_CLEAN;
  fp_enable();
//   f_p[0] = 1.1f;
  __asm__ volatile("nop");
  __asm__ volatile("csrw mstatus, %0" : : "r"(f_s));
  __asm__ volatile("nop");
  __asm__ volatile("mulh %0, %1, %2" : "=r"(mul64) : "r"(a), "r"(b));
  __asm__ volatile("flw f5, 0(a5)");// : "=r"(f_res) : "r"(f_p));
  __asm__ volatile("csrw mstatus, %0" : : "r"(f_s));
  __asm__ volatile("nop");


#endif

  return error;
}
