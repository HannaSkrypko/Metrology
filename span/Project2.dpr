program Project2;

{$APPTYPE CONSOLE}

uses
  SysUtils;

type

  TArrayNameVariable=array of string;
  TArraySumVariable=array of integer;

var
   f: textfile;
   

 procedure RemoveAndWriteNewFile();
   var
   FileWithCode,FileWithCleanCode: textfile;
   Pointer: integer;
   line:string;
   quotes,SingleLineComment,ManyLineComment,quote: boolean;

   begin
   assign(FileWithCode,'php.txt');
   reset(FileWithCode);
   assign(FileWithCleanCode,'phpClear.txt');
   rewrite(FileWithCleanCode);

   quotes:=false;
   ManyLineComment:=false;
   quote:=false;
   while not Eof(FileWithCode) do
     begin
     readln(FileWithCode,line);
     Pointer:=1;
     SingleLineComment:=false;
     while (Pointer<=length(line)) do
         begin

         if quotes then
            begin
            if line[Pointer]='"' then quotes:=false;
            delete(line,Pointer,1);
            Pointer:=Pointer-1;
            if line='' then break;
            end;

         if quote then
            begin
            if line[Pointer]=#39 then quote:=false;
            delete(line,Pointer,1);
            Pointer:=Pointer-1;
            if line='' then break;
            end;

         if ManyLineComment then
          begin
          if (line[Pointer]='*') and (line[Pointer+1]='/')
          then
            begin
            ManyLineComment:=false;
            delete(line,Pointer,1);
            end;
          delete(line,Pointer,1);
          Pointer:=Pointer-1;
          if line='' then break;
          end;

         if SingleLineComment then
            begin
            delete(line,Pointer,length(line)-Pointer+1);
            end;

         if not (SingleLineComment or quotes or ManyLineComment or quote) then
            begin
            if (line[Pointer]='{') or (line[Pointer]='}') or (line[Pointer]='(') or (line[Pointer]=')')then
              begin
              writeln(FileWithCleanCode,copy(line,1,Pointer-1));
              writeln(FileWithCleanCode,copy(line,Pointer,1));
              delete(line,1,Pointer);
              Pointer:=1;
              if line='' then break;
              end;

            if line[Pointer]='"' then
              begin
              delete(line,Pointer,1);
              Pointer:=Pointer-1;
              quotes:=true;
              end;

            if line[Pointer]=#39 then
              begin
              delete(line,Pointer,1);
              Pointer:=Pointer-1;
              quote:=true;
              end;

            if (line[Pointer]='#') then
              begin
              Pointer:=Pointer-1;
              SingleLineComment:=true;
              end;

            if ((line[Pointer]='/') and (line[Pointer-1]='/')) then
              begin
              Pointer:=Pointer-2;
              SingleLineComment:=true;
              end;

            if (line[Pointer]='*') and (line[Pointer-1]='/') then
              begin
              Pointer:=Pointer-2;
              ManyLineComment:=true;
              end

            end;
         Pointer:=Pointer+1;
         end;
     writeln(FileWithCleanCode,line);
     end;
   close(FileWithCleanCode);
   close(FileWithCode);
   end;

 function FoundOfTokens(var Pointer: integer; const line:string): string;
   begin
    result:='';
    while ((line[Pointer]=' ') or (line[Pointer]='[') or (line[Pointer]=']')
    or (line[Pointer]='(') or (line[Pointer]=')') or (line[Pointer]=',')
    or (line[Pointer]=';')) and (Pointer<=length(line)) do Pointer:=Pointer+1;
    while (line[Pointer]<>' ') and (line[Pointer]<>'[') and (line[Pointer]<>']')
    and (line[Pointer]<>'(') and (line[Pointer]<>')') and (line[Pointer]<>',')
    and (line[Pointer]<>';') and (Pointer<=length(line)) do
      begin
      result:=result+line[Pointer];
      Pointer:=Pointer+1;
      end;
   end;

  procedure includeFindVariableInArray(NameVariable: string;var Number: integer; var ArrayNameVariable:TArrayNameVariable; var ArraySumVariable:TArraySumVariable);
    begin
    Number:=Number+1;
    setlength(ArrayNameVariable,Number+1);
    ArrayNameVariable[Number]:=NameVariable;
    setlength(ArraySumVariable,Number+1);
    ArraySumVariable[Number]:=0;
    end;

  function ListVariableArray(const FindSpan:string;
  const ArrayNameVariable: TArrayNameVariable;
  const CountVariable:integer; var ArraySumVariable:TArraySumVariable):boolean;
  var
  i: integer;
   begin
   result:=false;

   for i:=1 to CountVariable do
    if FindSpan=ArrayNameVariable[i] then
      begin
      result:=true;
      ArraySumVariable[i]:=ArraySumVariable[i]+1;
      break;
      end;
   end;


  procedure FindSpan(const NameFunction:string);
  var
  ArrayNameVariable:TArrayNameVariable;
  ArraySumVariable:TArraySumVariable;

  line,Token: string;
  Pointer: integer;
  FunctionFlag:boolean;
  CountVariable,Nesting,i:integer;
  NameSubFunction:string;

    begin
    setlength(ArrayNameVariable,1);
    setlength(ArraySumVariable,1);
    CountVariable:=0;
    FunctionFlag:=true;
    Nesting:=0;

    while not Eof(F) do
     begin
     readln(f,line);
     Trim(line);
     Pointer:=1;
     while (Pointer <= Length(line)) do
       begin
       Token:=FoundOfTokens(Pointer,line);
       if Token<>'' then
        begin
        if Token='function' then
          begin
          NameSubFunction:='';
          while NameSubFunction='' do NameSubFunction:=FoundOfTokens(Pointer,line);
          FindSpan(NameSubFunction);
          end;
        if (Token[1]='$') then
          if (not ListVariableArray(Token,ArrayNameVariable,CountVariable,ArraySumVariable))
            then includeFindVariableInArray(Token,CountVariable,ArrayNameVariable,ArraySumVariable);
        if ((Token='{') and (not FunctionFlag)) then Nesting:=Nesting+1;
        if (Token='}') or (Token='?>') then Nesting:=Nesting-1;
        if ((Nesting=0) and (not FunctionFlag)) then
          begin
          writeln(NameFunction,':');
          for i:=1 to CountVariable do writeln(ArrayNameVariable[i],'=',ArraySumVariable[i]);
          writeln('end ', NameFunction);
          writeln;
          exit;
          end;
        if (((Token='{') or (Token='<?php')) and FunctionFlag) then
          begin
          FunctionFlag:=false;
          Nesting:=Nesting+1;
          end;
        end;
       end;
     end;

    end;


begin
   RemoveAndWriteNewFile();

   assign(f,'phpClear.txt');
   reset(f);

   FindSpan('Main');

   close(f);

   readln;
end.
