program concatenate_resourestrings_delphiunicode;

{$mode delphiunicode}
{$codepage cp1250}

{$ifdef unix}
uses
  {$ifdef darwin}iosxwstr{$else}cwstring{$endif};
{$endif}

resourcestring
  res2 = '�lu�ou�k� ' + 'kon��ek';

type
  tstr1250 = type ansistring(1250);
var
  str1250: tstr1250;
begin
  str1250 := '�lu�ou�k� ' + 'kon��ek';
  if res2<>str1250 then
    halt(1);
end.
