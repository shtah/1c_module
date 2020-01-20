﻿///////////////////////////////////////////////////////////////////////////////////
// Модуль - Blake2b Клиент Сервер
//
// MIT License Copyright (c) 2020 AcrylPlatform.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software 
// is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be 
// included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT 
// SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE 
// OR OTHER DEALINGS IN THE SOFTWARE.
//
// Blake2B in pure Javascript
// Adapted from the reference implementation in RFC7693
// Ported to Javascript by DC - https://github.com/dcposch
//
// Ported to 1C in 2019 by Artyom Serov
//
///////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////
#Область СлужебныеПроцедурыИФункции

///////////////////////////////////////////////////////////////////////////////////
#Область ОберткаОбщихФункций

Функция ПобитовыйСдвигВправоБеззнаковый(Число, Смещение)
	
	Возврат Crypt_ОбщегоНазначенияКлиентСевер.ПобитовыйСдвигВправоСЗаполнениемНулями(Число, Смещение);
	
КонецФункции

Функция ПреведениеКДиапазону(Знач ТипизированныйМассив, Знач Число) Экспорт 
	
	Возврат Crypt_ТипизированныеМассивы.ПреведениеКДиапазону(ТипизированныйМассив, Число);
	
КонецФункции

#КонецОбласти
///////////////////////////////////////////////////////////////////////////////////

Функция blake2bInit(Длина, Ключ)
	
	Если Длина = 0 Или Длина > 64 Тогда 
		
		ВызватьИсключение "Illegal output length, expected 0 < length <= 64";	
		
	КонецЕсли;
	
	Если Ключ <> Неопределено Тогда 
		
		Если Ключ > 64 Тогда 
			
			ВызватьИсключение "Illegal key, expected Array with 0 < length <= 64";	
			
		КонецЕсли;
			
	КонецЕсли;
	
	BLAKE2B_IV32_T = BLAKE2B_IV32_Get();
	
	BLAKE2B_IV32 = BLAKE2B_IV32_T.BLAKE2B_IV32;
	
	Б_Т = Crypt_ТипизированныеМассивы.Uint8Array("б", 128);
	
	б = Б_Т.б;
	
	Для сч = 0 По 127 Цикл 
		
		б[сч] = 0;
		
	КонецЦикла;
		
	Х_Т = Crypt_ТипизированныеМассивы.Uint32Array("х", 16);
	х = Х_Т.х;
	
	т = 0;
	с = 0;

	
	Для сч = 0 По 15 Цикл 
		
		х[сч] = ПреведениеКДиапазону(Х_Т, BLAKE2B_IV32[сч]);
		
	КонецЦикла;
	
	ДлинаКлюча = ?(Ключ = Неопределено, 0, СтрДлина(Ключ));
	
	х[0] = ПреведениеКДиапазону(Х_Т, ПобитовоеИсключительноеИли(х[0], 
		ПобитовоеИсключительноеИли(ПобитовоеИсключительноеИли(16842752, ПобитовыйСдвигВлево(ДлинаКлюча, 8)),
									Длина)));
									
	стх = Новый Структура;
	стх.Вставить("Б", Б_Т);
	стх.Вставить("Х", Х_Т);
	стх.Вставить("т", т);
	стх.Вставить("с", с);
	стх.Вставить("Длина", Длина);
									
	Если Ключ <> Неопределено Тогда 
		
		blake2bUpdate(стх, Ключ);
		стх.с = 128;
		
	КонецЕсли;
	
	Возврат стх;
	
КонецФункции

Процедура blake2bUpdate(стх, вДанные)
	
	Для сч = 0 По вДанные.Количество() - 1 Цикл
		
		Если стх.с = 128 Тогда
			
			стх.т = стх.т + стх.с;
			
			blake2bCompress(стх, Ложь);
			
			стх.с = 0;
			
		КонецЕсли;
		
		стх.б.б[стх.с] = ПреведениеКДиапазону(стх.б, вДанные[сч]);
		
		стх.с = стх.с + 1;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура blake2bCompress(стх, Финал)
	 
	в_т = Crypt_ТипизированныеМассивы.Uint32Array("в32", 32);
	м_т = Crypt_ТипизированныеМассивы.Uint32Array("м32", 32);
	
	в = в_т.в32;
	м = м_т.м32;
	
	BLAKE2B_IV32_T = BLAKE2B_IV32_Get();
	BLAKE2B_IV32 = BLAKE2B_IV32_T.BLAKE2B_IV32;
	
	Для сч = 0 По 15 Цикл
		
		в[сч] = ПреведениеКДиапазону(в_т, стх.х.х[сч]);
		в[сч + 16] = ПреведениеКДиапазону(в_т, BLAKE2B_IV32[сч]);
		
	КонецЦикла;
	 
	в[24] = ПреведениеКДиапазону(в_т, ПобитовоеИсключительноеИли(в[24], стх.т));
	
	Если Цел(стх.т / 4294967296) Тогда 
	
		в[25] = ПреведениеКДиапазону(в_т, ПобитовоеИсключительноеИли(в[25], (стх.т / 4294967296)));
		
	КонецЕсли;
		
	Если Финал Тогда 
		
		в[28] = ПреведениеКДиапазону(в_т, ПобитовоеНе(в[28]));
		в[29] = ПреведениеКДиапазону(в_т, ПобитовоеНе(в[29]));
		
	КонецЕсли;
	
	Для сч = 0 По 31 Цикл
		
		м[сч] = B2B_GET32(стх.б.б, 4 * сч);	
		
	КонецЦикла;
	
	SIGMA82 = SIGMA82();
	
	Для сч = 0 По 11 Цикл 
		
		B2B_G(0, 8, 16, 24, SIGMA82[сч * 16 + 0], SIGMA82[сч * 16 + 1], м_т, в_т);	
		B2B_G(2, 10, 18, 26, SIGMA82[сч * 16 + 2], SIGMA82[сч * 16 + 3], м_т, в_т);
        B2B_G(4, 12, 20, 28, SIGMA82[сч * 16 + 4], SIGMA82[сч * 16 + 5], м_т, в_т);
        B2B_G(6, 14, 22, 30, SIGMA82[сч * 16 + 6], SIGMA82[сч * 16 + 7], м_т, в_т);
        B2B_G(0, 10, 20, 30, SIGMA82[сч * 16 + 8], SIGMA82[сч * 16 + 9], м_т, в_т);
        B2B_G(2, 12, 22, 24, SIGMA82[сч * 16 + 10], SIGMA82[сч * 16 + 11], м_т, в_т);
        B2B_G(4, 14, 16, 26, SIGMA82[сч * 16 + 12], SIGMA82[сч * 16 + 13], м_т, в_т);
        B2B_G(6, 8, 18, 28, SIGMA82[сч * 16 + 14], SIGMA82[сч * 16 + 15], м_т, в_т);
		
	КонецЦикла;
	
	Для сч = 0 По 15 Цикл 
		
		стх.х.х[сч] = ПреведениеКДиапазону(стх.х, ПобитовоеИсключительноеИли(
			ПобитовоеИсключительноеИли(стх.х.х[сч], в[сч]),
			в[сч + 16]));
		
	КонецЦикла;
	
КонецПроцедуры

Процедура B2B_G(а, б, с, д, сч, счч, м_т, в_т)
	
	м = м_т.м32;
	в = в_т.в32;
	
	х0 = м[сч];
	х1 = м[сч + 1];
	у0 = м[счч];
	у1 = м[счч + 1];
	
	ADD64AA(в_т, а, б);
	ADD64AC(в_т, а, х0, х1);
	
	xor0 = ПобитовоеИсключительноеИли(в[д], в[а]);
    xor1 = ПобитовоеИсключительноеИли(в[д + 1], в[а + 1]);
	
	в[д] = ПреведениеКДиапазону(в_т, xor1);
    в[д + 1] = ПреведениеКДиапазону(в_т, xor0);
	
    ADD64AA(в_т, с, д);
	
	xor0 = ПобитовоеИсключительноеИли(в[б], в[с]);
    xor1 = ПобитовоеИсключительноеИли(в[б + 1], в[с + 1]);
	
	в[б] = ПреведениеКДиапазону(в_т, ПобитовоеИсключительноеИли(
		ПобитовыйСдвигВправоБеззнаковый(xor0, 24), 
		ПобитовыйСдвигВлево(xor1, 8)));
		
	в[б + 1] = ПреведениеКДиапазону(в_т, ПобитовоеИсключительноеИли(
		ПобитовыйСдвигВправоБеззнаковый(xor1, 24),
		ПобитовыйСдвигВлево(xor0, 8)));
		
	ADD64AA(в_т, а, б);
	ADD64AC(в_т, а, у0, у1);      
	
	xor0 = ПобитовоеИсключительноеИли(в[д], в[а]);
    xor1 = ПобитовоеИсключительноеИли(в[д + 1], в[а + 1]);
    в[д] = ПреведениеКДиапазону(в_т, ПобитовоеИсключительноеИли(
		ПобитовыйСдвигВправоБеззнаковый(xor0, 16),
		ПобитовыйСдвигВлево(xor1, 16)));
		
    в[д + 1] = ПреведениеКДиапазону(в_т, ПобитовоеИсключительноеИли(
		ПобитовыйСдвигВправоБеззнаковый(xor1, 16),
		ПобитовыйСдвигВлево(xor0, 16)));
		
    ADD64AA(в_т, с, д);
    
	xor0 = ПобитовоеИсключительноеИли(в[б], в[с]);
    xor1 = ПобитовоеИсключительноеИли(в[б + 1] , в[с + 1]);
	
	в[б] = ПреведениеКДиапазону(в_т, ПобитовоеИсключительноеИли(
		ПобитовыйСдвигВправоБеззнаковый(xor1, 31),
		ПобитовыйСдвигВлево(xor0, 1)));
		
    в[б + 1] = ПреведениеКДиапазону(в_т, ПобитовоеИсключительноеИли(
		ПобитовыйСдвигВправоБеззнаковый(xor0, 31),
		ПобитовыйСдвигВлево(xor1, 1)));
	
КонецПроцедуры

Процедура ADD64AA(в_т, а, б)
	
	в = в_т.в32;
	
	о0 = в[а] + в[б];
	о1 = в[а + 1] + в[б + 1];
	
	Если о0 >= 4294967296 Тогда
		
		о1 = о1 + 1;
		
	КонецЕсли;
	
	в[а] = ПреведениеКДиапазону(в_т, о0); 	
	
	в[а + 1] = ПреведениеКДиапазону(в_т, о1);

	
КонецПроцедуры

Процедура ADD64AC(в_т, а, б0, б1)
	
	в = в_т.в32;
	
	о0 = в[а] + б0;
	
	Если б0 < 0 Тогда 
		
		о0 = о0 + 4294967296;
		
	КонецЕсли;
	
	о1 = в[а + 1] + б1;
	
	Если о0 >= 4294967296 Тогда 
		
		о1 = о1 + 1;
		
	КонецЕсли;
	
	в[а] = ПреведениеКДиапазону(в_т, о0);	

	в[а + 1] = ПреведениеКДиапазону(в_т, о1);
			
КонецПроцедуры

Функция SIGMA()
	
	Сигма8 = Новый Массив; 
	
	Сигма8.Добавить("0");
	Сигма8.Добавить("1");
	Сигма8.Добавить("2");
	Сигма8.Добавить("3");
	Сигма8.Добавить("4");
	Сигма8.Добавить("5");
	Сигма8.Добавить("6");
	Сигма8.Добавить("7");
	Сигма8.Добавить("8");
	Сигма8.Добавить("9");
	Сигма8.Добавить("10");
	Сигма8.Добавить("11");
	Сигма8.Добавить("12");
	Сигма8.Добавить("13");
	Сигма8.Добавить("14");
	Сигма8.Добавить("15");
	Сигма8.Добавить("14");
	Сигма8.Добавить("10");
	Сигма8.Добавить("4");
	Сигма8.Добавить("8");
	Сигма8.Добавить("9");
	Сигма8.Добавить("15");
	Сигма8.Добавить("13");
	Сигма8.Добавить("6");
	Сигма8.Добавить("1");
	Сигма8.Добавить("12");
	Сигма8.Добавить("0");
	Сигма8.Добавить("2");
	Сигма8.Добавить("11");
	Сигма8.Добавить("7");
	Сигма8.Добавить("5");
	Сигма8.Добавить("3");
	Сигма8.Добавить("11");
	Сигма8.Добавить("8");
	Сигма8.Добавить("12");
	Сигма8.Добавить("0");
	Сигма8.Добавить("5");
	Сигма8.Добавить("2");
	Сигма8.Добавить("15");
	Сигма8.Добавить("13");
	Сигма8.Добавить("10");
	Сигма8.Добавить("14");
	Сигма8.Добавить("3");
	Сигма8.Добавить("6");
	Сигма8.Добавить("7");
	Сигма8.Добавить("1");
	Сигма8.Добавить("9");
	Сигма8.Добавить("4");
	Сигма8.Добавить("7");
	Сигма8.Добавить("9");
	Сигма8.Добавить("3");
	Сигма8.Добавить("1");
	Сигма8.Добавить("13");
	Сигма8.Добавить("12");
	Сигма8.Добавить("11");
	Сигма8.Добавить("14");
	Сигма8.Добавить("2");
	Сигма8.Добавить("6");
	Сигма8.Добавить("5");
	Сигма8.Добавить("10");
	Сигма8.Добавить("4");
	Сигма8.Добавить("0");
	Сигма8.Добавить("15");
	Сигма8.Добавить("8");
	Сигма8.Добавить("9");
	Сигма8.Добавить("0");
	Сигма8.Добавить("5");
	Сигма8.Добавить("7");
	Сигма8.Добавить("2");
	Сигма8.Добавить("4");
	Сигма8.Добавить("10");
	Сигма8.Добавить("15");
	Сигма8.Добавить("14");
	Сигма8.Добавить("1");
	Сигма8.Добавить("11");
	Сигма8.Добавить("12");
	Сигма8.Добавить("6");
	Сигма8.Добавить("8");
	Сигма8.Добавить("3");
	Сигма8.Добавить("13");
	Сигма8.Добавить("2");
	Сигма8.Добавить("12");
	Сигма8.Добавить("6");
	Сигма8.Добавить("10");
	Сигма8.Добавить("0");
	Сигма8.Добавить("11");
	Сигма8.Добавить("8");
	Сигма8.Добавить("3");
	Сигма8.Добавить("4");
	Сигма8.Добавить("13");
	Сигма8.Добавить("7");
	Сигма8.Добавить("5");
	Сигма8.Добавить("15");
	Сигма8.Добавить("14");
	Сигма8.Добавить("1");
	Сигма8.Добавить("9");
	Сигма8.Добавить("12");
	Сигма8.Добавить("5");
	Сигма8.Добавить("1");
	Сигма8.Добавить("15");
	Сигма8.Добавить("14");
	Сигма8.Добавить("13");
	Сигма8.Добавить("4");
	Сигма8.Добавить("10");
	Сигма8.Добавить("0");
	Сигма8.Добавить("7");
	Сигма8.Добавить("6");
	Сигма8.Добавить("3");
	Сигма8.Добавить("9");
	Сигма8.Добавить("2");
	Сигма8.Добавить("8");
	Сигма8.Добавить("11");
	Сигма8.Добавить("13");
	Сигма8.Добавить("11");
	Сигма8.Добавить("7");
	Сигма8.Добавить("14");
	Сигма8.Добавить("12");
	Сигма8.Добавить("1");
	Сигма8.Добавить("3");
	Сигма8.Добавить("9");
	Сигма8.Добавить("5");
	Сигма8.Добавить("0");
	Сигма8.Добавить("15");
	Сигма8.Добавить("4");
	Сигма8.Добавить("8");
	Сигма8.Добавить("6");
	Сигма8.Добавить("2");
	Сигма8.Добавить("10");
	Сигма8.Добавить("6");
	Сигма8.Добавить("15");
	Сигма8.Добавить("14");
	Сигма8.Добавить("9");
	Сигма8.Добавить("11");
	Сигма8.Добавить("3");
	Сигма8.Добавить("0");
	Сигма8.Добавить("8");
	Сигма8.Добавить("12");
	Сигма8.Добавить("2");
	Сигма8.Добавить("13");
	Сигма8.Добавить("7");
	Сигма8.Добавить("1");
	Сигма8.Добавить("4");
	Сигма8.Добавить("10");
	Сигма8.Добавить("5");
	Сигма8.Добавить("10");
	Сигма8.Добавить("2");
	Сигма8.Добавить("8");
	Сигма8.Добавить("4");
	Сигма8.Добавить("7");
	Сигма8.Добавить("6");
	Сигма8.Добавить("1");
	Сигма8.Добавить("5");
	Сигма8.Добавить("15");
	Сигма8.Добавить("11");
	Сигма8.Добавить("9");
	Сигма8.Добавить("14");
	Сигма8.Добавить("3");
	Сигма8.Добавить("12");
	Сигма8.Добавить("13");
	Сигма8.Добавить("0");
	Сигма8.Добавить("0");
	Сигма8.Добавить("1");
	Сигма8.Добавить("2");
	Сигма8.Добавить("3");
	Сигма8.Добавить("4");
	Сигма8.Добавить("5");
	Сигма8.Добавить("6");
	Сигма8.Добавить("7");
	Сигма8.Добавить("8");
	Сигма8.Добавить("9");
	Сигма8.Добавить("10");
	Сигма8.Добавить("11");
	Сигма8.Добавить("12");
	Сигма8.Добавить("13");
	Сигма8.Добавить("14");
	Сигма8.Добавить("15");
	Сигма8.Добавить("14");
	Сигма8.Добавить("10");
	Сигма8.Добавить("4");
	Сигма8.Добавить("8");
	Сигма8.Добавить("9");
	Сигма8.Добавить("15");
	Сигма8.Добавить("13");
	Сигма8.Добавить("6");
	Сигма8.Добавить("1");
	Сигма8.Добавить("12");
	Сигма8.Добавить("0");
	Сигма8.Добавить("2");
	Сигма8.Добавить("11");
	Сигма8.Добавить("7");
	Сигма8.Добавить("5");
	Сигма8.Добавить("3");
	
	Возврат Сигма8;

	
КонецФункции

Функция SIGMA82()
	
	Сигма = SIGMA();
	
	Сигма2_Т = Crypt_ТипизированныеМассивы.Uint8Array("Сигима2");
	
	Сигма2 = Сигма2_Т.Сигима2;
	
	Для Каждого Элемент Из Сигма Цикл 
		
		Сигма2.Добавить(ПреведениеКДиапазону(Сигма2_Т, Элемент * 2));
		
	КонецЦикла;
	
	Возврат Сигма2;
	
КонецФункции

Функция B2B_GET32(б, сч)
	
	Возврат ПобитовоеИсключительноеИли(		
				ПобитовоеИсключительноеИли(ПобитовоеИсключительноеИли(б[сч],
	        		ПобитовыйСдвигВлево(б[сч + 1], 8)),
	        			ПобитовыйСдвигВлево(б[сч + 2], 16)),
	        				ПобитовыйСдвигВлево(б[сч + 3], 24));
							
КонецФункции

Функция blake2bFinal(стх)
	
	стх.т = стх.т + стх.с;
	
	Пока стх.с < 128 Цикл 
		
		стх.б.б[стх.с] = 0;
		
		стх.с = стх.с + 1;
		
	КонецЦикла;
	
	blake2bCompress(стх, Истина);
	
	out_t = Crypt_ТипизированныеМассивы.Uint8Array("out", стх.длина);
	
	out = out_t.out;
	
	Для i = 0 По стх.длина - 1 Цикл
		
		 out[i] = ПреведениеКДиапазону(out_t, ПобитовыйСдвигВправо(стх.х.х[ПобитовыйСдвигВправо(i, 2)], (8 * ПобитовоеИ(i, 3))));		
		
	КонецЦикла;
	
    Возврат out_t;
		
КонецФункции

Функция BLAKE2B_IV32_Get()
	
	BLAKE2B_IV32_Т = Crypt_ТипизированныеМассивы.Uint32Array("BLAKE2B_IV32");
	
	BLAKE2B_IV32 = BLAKE2B_IV32_Т.BLAKE2B_IV32;
	
	BLAKE2B_IV32.Добавить(ПреведениеКДиапазону(BLAKE2B_IV32_Т, 4089235720));
	BLAKE2B_IV32.Добавить(ПреведениеКДиапазону(BLAKE2B_IV32_Т, 1779033703));
	BLAKE2B_IV32.Добавить(ПреведениеКДиапазону(BLAKE2B_IV32_Т, 2227873595));
	BLAKE2B_IV32.Добавить(ПреведениеКДиапазону(BLAKE2B_IV32_Т, 3144134277));
	
	BLAKE2B_IV32.Добавить(ПреведениеКДиапазону(BLAKE2B_IV32_Т, 4271175723));
	BLAKE2B_IV32.Добавить(ПреведениеКДиапазону(BLAKE2B_IV32_Т, 1013904242));
	BLAKE2B_IV32.Добавить(ПреведениеКДиапазону(BLAKE2B_IV32_Т, 1595750129));
	BLAKE2B_IV32.Добавить(ПреведениеКДиапазону(BLAKE2B_IV32_Т, 2773480762));
	
	BLAKE2B_IV32.Добавить(ПреведениеКДиапазону(BLAKE2B_IV32_Т, 2917565137));
	BLAKE2B_IV32.Добавить(ПреведениеКДиапазону(BLAKE2B_IV32_Т, 1359893119));
	BLAKE2B_IV32.Добавить(ПреведениеКДиапазону(BLAKE2B_IV32_Т, 725511199));
	BLAKE2B_IV32.Добавить(ПреведениеКДиапазону(BLAKE2B_IV32_Т, 2600822924));
	
	BLAKE2B_IV32.Добавить(ПреведениеКДиапазону(BLAKE2B_IV32_Т, 4215389547));
	BLAKE2B_IV32.Добавить(ПреведениеКДиапазону(BLAKE2B_IV32_Т, 528734635));
	BLAKE2B_IV32.Добавить(ПреведениеКДиапазону(BLAKE2B_IV32_Т, 327033209));
	BLAKE2B_IV32.Добавить(ПреведениеКДиапазону(BLAKE2B_IV32_Т, 1541459225));
	
	Возврат BLAKE2B_IV32_Т;
	
КонецФункции

#КонецОбласти
///////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////
#Область ПрограммныйИнтерфейс

Функция blake2b(Знач вДанные, Знач Ключ = Неопределено, Знач Длина = 32) Экспорт
	
	Если Длина = Неопределено Тогда 
		
		Длина = 64;
		
	КонецЕсли;
	
	Если ТипЗнч(вДанные) = ТипЗнч("") Тогда 
		
		вДанные	= Crypt_Utf8.СтрокаВUtf8МассивБайт(вДанные);
		
	ИначеЕсли ТипЗнч(вДанные) <> ТипЗнч(Новый Массив) Тогда
		
		ВызватьИсключение "Input must be an String or Array";	
		
	КонецЕсли;
	
	стх = blake2bInit(Длина, Ключ);
	
	blake2bUpdate(стх, вДанные);
	
	Возврат blake2bFinal(стх);
	
КонецФункции

#КонецОбласти
////////////////////////////////////////////////////////////////////////////////////