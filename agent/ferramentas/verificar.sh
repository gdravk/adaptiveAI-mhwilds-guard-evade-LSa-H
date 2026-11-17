#!/bin/bash
# Roda todas as verificacoes num arquivo do mod. Uso: verificar.sh arquivo.lua [versao_anterior.lua]
S="$(cd "$(dirname "$0")" && pwd)"
F="$1"; ANT="$2"; erros=0
echo "== $F"
r=$(perl "$S/sintaxe.pl" < "$F"); echo "1 sintaxe: $r"; [[ "$r" == sintaxe\ OK* ]] || erros=$((erros+1))
r=$(perl "$S/escopo2.pl" < "$F"); n=$(echo "$r" | grep -c "nao e local visivel"); echo "2 fora do alcance: $n"; [ "$n" -eq 0 ] || { echo "$r" | grep "nao e local"; erros=$((erros+1)); }
g=$(echo "$r" | grep "globais definidas" | sed 's/globais definidas: //'); echo "3 globais criadas sem querer: ${g:-nenhuma}"; [ -z "$g" ] || erros=$((erros+1))
c=$(echo "$r" | grep -oE "chunk=[0-9]+" | cut -d= -f2); echo "4 locais na parte principal: $c (limite 200)"; [ "$c" -lt 195 ] || erros=$((erros+1))
b=$(java "$S/LuaCheck.java" "$F" | head -c 25); echo "5 blocos: $b"; [[ "$b" == "open at EOF: [] lines []"* ]] || erros=$((erros+1))
a=$(LC_ALL=C grep -c -P '[\x80-\xFF]' "$F"); echo "6 acentos: $a"; [ "$a" -eq 0 ] || erros=$((erros+1))
grep -oE "n78\.[a-z_0-9]+" "$F" | sort -u > "$S/u.txt"; grep -oE "n78\.[a-z_0-9]+ = |function n78\.[a-z_0-9]+" "$F" | sed -E 's/function //; s/ = //' | sort -u > "$S/d.txt"
n=$(comm -23 "$S/u.txt" "$S/d.txt" | wc -l); echo "7 funcoes n78 sem definicao: $n"; [ "$n" -eq 0 ] || { comm -23 "$S/u.txt" "$S/d.txt"; erros=$((erros+1)); }
n=$(grep -oE "^\s*n78\.[a-z_0-9]+ = |function n78\.[a-z_0-9]+" "$F" | sed -E 's/function //; s/ = //; s/^\s+//' | sort | uniq -d | wc -l); echo "8 funcoes n78 definidas 2 vezes: $n"; [ "$n" -eq 0 ] || erros=$((erros+1))
s=$(grep -n "^local op = {" "$F" | cut -d: -f1); e=$(awk -v s=$s 'NR>s && /^};/ {print NR; exit}' "$F")
awk -v s=$s -v e=$e 'NR>=s && NR<=e' "$F" | grep -oE "^	[a-z_0-9]+ =" | sed -E 's/^	//; s/ =//' | sort -u > "$S/od.txt"; grep -oE "op\.[a-z_0-9]+" "$F" | sed 's/op\.//' | sort -u > "$S/oa.txt"
n=$(comm -13 "$S/od.txt" "$S/oa.txt" | wc -l); echo "9 opcoes sem valor padrao: $n"; [ "$n" -eq 0 ] || { comm -13 "$S/od.txt" "$S/oa.txt"; erros=$((erros+1)); }
v=$(grep -oE 'versao_mod = "[0-9.]+"' "$F" | sort -u | wc -l); echo "10 versoes diferentes no arquivo: $v"; [ "$v" -eq 1 ] || erros=$((erros+1))
if [ -n "$ANT" ]; then
	novos=$(diff <(grep -oE "estado\.[a-z_0-9]+" "$ANT" | sort -u) <(grep -oE "estado\.[a-z_0-9]+" "$F" | sort -u) | grep '^>' | sed 's/^> //')
	echo "11 nomes novos em estado: ${novos:-nenhum}"
fi
echo "RESULTADO: $erros problema(s)"
