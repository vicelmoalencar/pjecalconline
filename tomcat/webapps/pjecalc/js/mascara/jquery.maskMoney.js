/*
* @Copyright (c) 2010 Aurélio Saraiva, Diego Plentz
* @Page http://github.com/plentz/jquery-maskmoney
* try at http://inoveideia.com.br/maskInputMoney/

* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without
* restriction, including without limitation the rights to use,
* copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following
* conditions:
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
* OTHER DEALINGS IN THE SOFTWARE.
*/

/*
* @Version: 0.9
* @Release: 2011-01-10
*/


/*
 * @Vers�o: 1.0
 * @Release: 21/03/2011
 * @Autor: Kaio Valente
 * 
 * Funcionalidades Adicionadas:
 * 
 * - Aceita zero como valor final (Ex.: 0,0000)
 * - Aceita tecla tab
 * - Aplica��o da m�scara com a utiliza��o do ctrl+v
 * - Permite copiar o valor do campo com ctrl+c
 * - Habilitada navega��o pelo teclado
 * - Tratamento para copiar e colar do mouse (Evento blur)
 * - Adicionada fun��o aplicaDecimal() para aplicar o separador
 *   decimal: Corre��o de bug (campos estourando com valores muito altos)
 * - Adicionado parametro 'max' para definir numero m�ximo de caracteres
 * - Corrigida verifica��o de maxlength 
 */

(function($) {
	$.fn.maskMoney = function(settings) {
		
		settings = $.extend({
			symbol:'R$',
			decimal:',',
			precision:2,
			thousands:'.',
			allowZero:true,
			allowNegative:false,
			showSymbol:false,
			symbolStay:false,
			defaultZero:false,
			max:'26'
		}, settings);

		return this.each(function() {
			
			
			
			var input = $(this);
			
			function keypressEvent(e) {
				e = e||window.event;
				var k = e.charCode||e.keyCode||e.which;
				if (k == undefined) return false; //needed to handle an IE "special" event
				
				var max = input.attr('maxlength') == '-1' ? settings.max : input.attr('maxlength');

				if (k<48||k>57) { // any key except the numbers 0-9
					if (k==45) { // -(minus) key
						input.val(changeSign(input));
						return false;
					}
					if (k==43) { // +(plus) key
						input.val(input.val().replace('-',''));
						return false;
					} else if (k==13 || k==9) { // Enter ou Tab
						return true;
					} else { // any other key with keycode less than 48 and greater than 57
						if ( (k != 118 && k != 99)  && (k<35||k>40) ) { // k=118: ctrl+v
							preventDefault(e);
						}
						return true;
					}
				} else if ( ( input.val().length>=max ) || ( input.val().length >= settings.max) ) {
					preventDefault(e);
					
					var texto = maskValue(input.val().substring(1, input.val().length) + String.fromCharCode(k));
					input.val(texto);
					return false;
				} else {
					preventDefault(e);

					var key = String.fromCharCode(k);
					var x = input.get(0);
					var selection = input.getInputSelection(x);
					var startPos = selection.start;
					var endPos = selection.end;
					x.value = x.value.substring(0, startPos) + key + x.value.substring(endPos, x.value.length);
					maskAndPosition(x, startPos + 1);
					return false;
				}
			}

			function keydownEvent(e) {
				e = e||window.event;
				var k = e.charCode||e.keyCode||e.which;
				if (k == undefined) return false; //needed to handle an IE "special" event

				var x = input.get(0);
				var selection = input.getInputSelection(x);
				var startPos = selection.start;
				var endPos = selection.end;
				if (k==8) { // backspace key
				preventDefault(e);

					var isZero = validaZero(x.value);
					if(startPos == endPos)
					{
						// Remove single character
						x.value = x.value.substring(0, startPos - 1) + x.value.substring(endPos, x.value.length);
						startPos = startPos - 1;
					}
					else
					{
						// Remove multiple characters
						x.value = x.value.substring(0, startPos) + x.value.substring(endPos, x.value.length);
					}
					
					//Permite apagar zeros
					if (isZero != '')
						maskAndPosition(x, startPos);
					else
						input.val('');
						
					return false;
				} else if (k==9) { // tab key
					return true;
				} else if (k==46||k==63272) { // delete key (with special case for safari)
					preventDefault(e);
					if(x.selectionStart == x.selectionEnd)
					{
						// Remove single character
						x.value = x.value.substring(0, startPos) + x.value.substring(endPos + 1, x.value.length);
					}
					else
					{
						//Remove multiple characters
						x.value = x.value.substring(0, startPos) + x.value.substring(endPos, x.value.length);
					}
					maskAndPosition(x, startPos);
					return false;
				} else { // any other key
					return true;
				}
			}
			
			//Tratamento para ctrl+v
			function keyupEvent(e) {
				e = e||window.event;
				var k = e.charCode||e.keyCode||e.which;
				if (k == undefined) return false; //needed to handle an IE "special" event
				
				if (e.ctrlKey && k==86) {
					var x = input.get(0);
					var selection = input.getInputSelection(x);
					var startPos = selection.start;
					maskAndPosition(x, startPos);
				}
			}

			function focusEvent(e) {
				if (input.val()==''&&settings.defaultZero) {
					input.val(setSymbol(getDefaultMask()));
				} else {
					input.val(setSymbol(input.val()));
				}
                if (this.createTextRange) {
                    var textRange = this.createTextRange();
                    textRange.collapse(false); // set the cursor at the end of the input
                    textRange.select();
                }
			}

			function blurEvent(e) {
                if ($.browser.msie) {
                    keypressEvent(e);
                }

	            var x = input.get(0);					
				input.val(maskValue(x.value));

				if (input.val()==setSymbol(getDefaultMask())) {
					if(!settings.allowZero) input.val('');
				} else {
					if (!settings.symbolStay) input.val(input.val().replace(settings.symbol,''));
					else if (settings.symbolStay&&input.val()==settings.symbol) input.val('');
				}
			}

			function preventDefault(e) {
				if (e.preventDefault) { //standard browsers
					e.preventDefault();
				} else { // internet explorer
					e.returnValue = false;
				}
			}

			function maskAndPosition(x, startPos) {
				var originalLen = input.val().length;
				input.val(maskValue(x.value));
				var newLen = input.val().length;
				startPos = startPos - (originalLen - newLen);
				input.setCursorPosition(startPos);
			}

			function maskValue(v) {
				v = v.replace(settings.symbol,'');

				var strCheck = '0123456789';
				var len = v.length;
				var a = '', t = '', neg='';

				if(len!=0 && v.charAt(0)=='-'){
					v = v.replace('-','');
					if(settings.allowNegative){
						neg = '-';
					}
				}

				if (len==0) {
					if (!settings.defaultZero) return t;
					t = '0.00';
				}

				for (var i = 0; i<len; i++) {
					if ((v.charAt(i)!='0') && (v.charAt(i)!=settings.decimal)) break;
                }

				for (; i<len; i++) {
					if (strCheck.indexOf(v.charAt(i))!=-1) a+= v.charAt(i);
				}

				var n = parseFloat(a);
				
				n = isNaN(n) ? 0 : n/Math.pow(10,settings.precision);
				
				if (a.length < 15)
					t = n.toFixed(settings.precision);
				else
					t = aplicaDecimal(a,settings.precision);

                i = settings.precision == 0 ? 0 : 1;
                
				var p, d = (t=t.split('.'))[i].substr(0,settings.precision);
				
				for (p = (t=t[0]).length; (p-=3)>=1;) {
					t = t.substr(0,p)+settings.thousands+t.substr(p);
				}

				return (settings.precision>0)
                    ? setSymbol(neg+t+settings.decimal+d+Array((settings.precision+1)-d.length).join(0))
                    : setSymbol(neg+t);
			}

			function getDefaultMask() {
				var n = parseFloat('0')/Math.pow(10,settings.precision);
				return (n.toFixed(settings.precision)).replace(new RegExp('\\.','g'),settings.decimal);
			}

			function setSymbol(v) {
				if (settings.showSymbol) {
					if (v.substr(0, settings.symbol.length) != settings.symbol) return settings.symbol+v;
				}
				return v;
			}

			function changeSign(i){
				if (settings.allowNegative) {
					var vic = i.val();
					if (i.val()!='' && i.val().charAt(0)=='-'){
						return i.val().replace('-','');
					} else{
						return '-'+i.val();
					}
				} else {
					return i.val();
				}
			}
			
			//Monta o n�mero com casas decimais
			function aplicaDecimal(numero, decimal) {
				
				var tamanho = numero.length;
				
				var pre = numero.substring(0,tamanho-decimal);
				var pos = numero.substring(tamanho-decimal);
				
				numero = pre+'.'+pos;
				
				return numero;
			}
			
			function validaZero(numero) {
				
				var array = new Array();
				
				if (numero == '')
					return;
				
				array = numero.split(',');
				
				pre = array[0];
				pos = array[1];
				
				if ( (pre == 0) && (pos.length <= settings.precision) && (pos <= 0) ) {
					return '';
				} 
				
				return numero;
			}
			
			input.bind('keyup',keyupEvent); // ctrl+v
			input.bind('keypress',keypressEvent);
			input.bind('keydown',keydownEvent);
			input.bind('blur',blurEvent); // tratamento para copiar e colar (mouse)
			input.bind('focus',focusEvent);

			input.one('unmaskMoney',function() {
				input.unbind('focus',focusEvent);
				input.unbind('blur',blurEvent);
				input.unbind('keydown',keydownEvent);
				input.unbind('keypress',keypressEvent);
				input.bind('keyup',keyupEvent);

				if ($.browser.msie) {
                    this.onpaste= null;
				} else if ($.browser.mozilla) {
                    this.removeEventListener('input',blurEvent,false);
                }
			});
			
		});
	}

	$.fn.unmaskMoney=function() {
		return this.trigger('unmaskMoney');
	};
	
	$.fn.setCursorPosition = function(pos) {
		
		this.each(function(index, elem) {
			if (elem.setSelectionRange) {
				elem.focus();
				elem.setSelectionRange(pos, pos);
			} else if (elem.createTextRange) {
				var range = elem.createTextRange();
				range.collapse(true);
				range.moveEnd('character', pos);
				range.moveStart('character', pos);
				range.select();
			}
		});
		return this;
	};
	
	$.fn.getInputSelection = function(el) {
		var start = 0, end = 0, normalizedValue, range, textInputRange, len, endRange;

		if (typeof el.selectionStart == "number" && typeof el.selectionEnd == "number") {
			start = el.selectionStart;
			end = el.selectionEnd;
		} else {
			range = document.selection.createRange();

			if (range && range.parentElement() == el) {
				len = el.value.length;
				normalizedValue = el.value.replace(/\r\n/g, "\n");

				// Create a working TextRange that lives only in the input
				textInputRange = el.createTextRange();
				textInputRange.moveToBookmark(range.getBookmark());

				// Check if the start and end of the selection are at the very end
				// of the input, since moveStart/moveEnd doesn't return what we want
				// in those cases
				endRange = el.createTextRange();
				endRange.collapse(false);

				if (textInputRange.compareEndPoints("StartToEnd", endRange) > -1) {
					start = end = len;
				} else {
					start = -textInputRange.moveStart("character", -len);
					start += normalizedValue.slice(0, start).split("\n").length - 1;

					if (textInputRange.compareEndPoints("EndToEnd", endRange) > -1) {
						end = len;
					} else {
						end = -textInputRange.moveEnd("character", -len);
						end += normalizedValue.slice(0, end).split("\n").length - 1;
					}
				}
			}
		}

		return {
			start: start,
			end: end
		};
	}
	
})(jQuery);