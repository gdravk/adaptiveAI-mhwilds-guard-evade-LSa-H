import java.nio.file.*; import java.util.*;
public class LuaCheck { public static void main(String[] a) throws Exception {
 String s = new String(Files.readAllBytes(Paths.get(a[0])), "UTF-8"); int i=0, n=s.length(), line=1;
 Deque<String> st = new ArrayDeque<>(); Deque<Integer> ln = new ArrayDeque<>(); Set<String> ids = new TreeSet<>(); Set<String> decl = new TreeSet<>();
 String prev="";
 while (i<n) { char c=s.charAt(i);
  if (c=='\n'){line++;i++;continue;}
  if (s.startsWith("--",i)) { if (s.startsWith("--[[",i)) { int e=s.indexOf("]]",i); for(int k=i;k<e;k++) if(s.charAt(k)=='\n') line++; i=e+2; } else { while(i<n&&s.charAt(i)!='\n') i++; } continue; }
  if (c=='"'||c=='\'') { int k=i+1; while(k<n&&s.charAt(k)!=c){ if(s.charAt(k)==(char)92)k++; if(s.charAt(k)=='\n'){System.out.println("unterminated string line "+line);} k++;} i=k+1; prev="str"; continue; }
  if (Character.isLetter(c)||c=='_') { int k=i; while(k<n&&(Character.isLetterOrDigit(s.charAt(k))||s.charAt(k)=='_'))k++; String w=s.substring(i,k);
    switch(w){ case "function": case "if": case "repeat": st.push(w); ln.push(line); break;
      case "do": if(!st.isEmpty() && (st.peek().equals("for")||st.peek().equals("while"))) { st.pop(); ln.pop(); } st.push("do"); ln.push(line); break;
      case "for": case "while": st.push(w); ln.push(line); break;
      case "end": if(st.isEmpty()){System.out.println("extra end line "+line);} else { String t=st.pop(); ln.pop(); if(t.equals("repeat")||t.equals("for")||t.equals("while")) System.out.println("bad end for "+t+" line "+line);} break;
      case "until": if(st.isEmpty()||!st.pop().equals("repeat")) System.out.println("bad until line "+line); else ln.pop(); break; }
    if (!prev.equals(".") && !prev.equals(":")) ids.add(w);
    if (prev.equals("local")||prev.equals("function")) decl.add(w);
    prev=w; i=k; continue; }
  if ("(){}[]".indexOf(c)>=0) { if("({[".indexOf(c)>=0){st.push(""+c);ln.push(line);} else { String o = c==')'?"(":c=='}'?"{":"["; if(st.isEmpty()||!st.peek().equals(o)) System.out.println("mismatched "+c+" line "+line+" top="+st.peek()+"@"+ln.peek()); else {st.pop();ln.pop();} } }
  if (!Character.isWhitespace(c)) prev=""+c;
  i++; }
 System.out.println("open at EOF: "+st+" lines "+ln);
 System.out.println("IDS:"+ids);
}}
