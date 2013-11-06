program tgeneric98;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

type
  TCondition<TElement: class> = class(TObject)
  end;

  TContainer<TElement: class> = class(TObject)
  public
    function  Contains(Element: TElement): Boolean; overload;
    function  Contains(Condition: TCondition<TElement>): Boolean; overload;
    procedure Test();
  end;

{ TContainer<TElement> }
  
procedure TContainer<TElement>.Test();
var
  Element: TElement;
begin
  Element := nil;
  Contains(Element); // Contains(TElement) should be called here as there is no ambiguity
end;
  
function TContainer<TElement>.Contains(Element: TElement): Boolean;
begin
end;

function TContainer<TElement>.Contains(Condition: TCondition<TElement>): Boolean;
begin
end;

var
  Container: TContainer<TObject>;
begin
  Container := TContainer<TObject>.Create();
  Container.Contains(TObject.Create());
  Container.Contains(TCondition<TObject>.Create());
  Container.Free();
end.
