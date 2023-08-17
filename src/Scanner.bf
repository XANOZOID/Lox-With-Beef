namespace vacon;
using System;

enum TokenType {
	TokenLeftParen, TokenRightParen,
	TokenLeftBrace, TokenRightBrace,
	TokenComma, TokenDot, TokenMinus, TokenPlus,
	TokenSemiColon, TokenSlash, TokenStar,
	// 1-2 Character Tokens....
	TokenBang, TokenBangEqual,
	TokenEqual, TokenEqualEqual,
	TokenGreater, TokenGreaterEqual,
	TokenLess, TokenLessEqual,
	// Literals
	TokenIdentifier, TokenString, TokenNumber,
	// Keywords
	TokenAnd, TokenClass, TokenElse, TokenFalse,
	TokenFor, TokenFun, TokenIf, TokenNil, TokenOr,
	TokenPrint, TokenReturn, TokenSuper, TokenThis,
	TokenTrue, TokenVar, TokenWhile,

	TokenError, TokenEOF
}

struct Token {
	public TokenType Type;
	public StringView Source;
	public int Line;
}

class Scanner {

	StringView Str;
	int64 Line = 1;

	public this(char8* source)  {
		Str = StringView(source, 0);
	}

	bool IsAlpha(char8 c) {
		return (c >= 'a' && c <= 'z') ||
			   (c >= 'A' && c <= 'Z') ||
			   (c == '_');
	}

	bool IsDigit(char8 c) {
	  return (c >= '0' && c <= '9');
	}

	bool IsAtEnd() {
		return (Str[[Unchecked] Str.Length] == '\0');
	}

	char8 Advance() {
		Str.Length ++;
		return Str[Str.Length - 1];
	}

	char8 Peek() {
		return Str[[Unchecked] Str.Length];
	}

	char8 PeekNext() {
		if (IsAtEnd()) return '\0';
		return Str[[Unchecked] Str.Length + 1];
	}

	bool Match(char8 expected) {
		if (IsAtEnd()) return false;
		if (Peek() != expected) return false;
		Str.Length ++;
		return true;
	}

	Token MakeToken(TokenType type) {
		Token t = Token {
			Type = type,
			Source = Str,
			Line = Line
		};
		return t;
	}
	

	Token ErrorToken(StringView err) {
		Token t = Token {
			Type = .TokenError,
			Source = err,
			Line = Line
		};
		return t;
	}

	void SkipWhitespace() {
		for (;;) {
			char8 c = Peek();

			switch(c) {
			case ' ', '\r', '\t':
				Advance();
			case '\n':
				Line ++;
				Advance();
			case '/':
				if (PeekNext() == '/') {
					while (Peek() != '\n' && !IsAtEnd())
						Advance();
					break;
				} else {
					return;
				}
			default:
				return;
			}
		}
	}

	TokenType IdentifierType() {
		switch (Str) {
		case "and": return .TokenAnd;
		case "class": return .TokenClass;
		case "else": return .TokenElse;
		case "false": return .TokenFalse;
		case "for": return .TokenFor;
		case "fun": return .TokenFun;
		case "if": return .TokenIf;
		case "nil": return .TokenNil;
		case "or": return .TokenOr;
		case "print": return .TokenPrint;
		case "return": return .TokenReturn;
		case "super": return .TokenSuper;
		case "this": return .TokenThis;
		case "true": return .TokenTrue;
		case "var": return .TokenVar;
		case "while": return .TokenWhile;
		}

		return .TokenIdentifier;
	}

	Token Identifier() {
		while (IsAlpha(Peek()) || IsDigit(Peek())) Advance();
		return MakeToken(IdentifierType());
	}

	Token Number() {
		while (IsDigit(Peek())) Advance();

		// look for fractional
		if (Peek() == '.' && IsDigit(PeekNext())) {
			// consume the decimal point
			Advance();
			while (IsDigit(Peek())) Advance();
		}

		return MakeToken(.TokenNumber);
	}

	Token String() {
		while (Peek() != '"' && !IsAtEnd()) {
			if (Peek() == '\n') Line ++;
			Advance();
		}

		if (IsAtEnd()) return ErrorToken("Unterminated string.");

		// closing quote
		Advance();
		return MakeToken(.TokenString);
	}

	public Token ScanToken() {
		SkipWhitespace();

		Str.Ptr += Str.Length;
		Str.Length = 0;

		if (IsAtEnd()) return MakeToken(.TokenEOF);

		char8 c = Advance();

		if (IsAlpha(c)) return Identifier();
		if (IsDigit(c)) return Number();


		switch (c) {
		case '(': return MakeToken(.TokenLeftParen);
		case ')': return MakeToken(.TokenRightParen);
		case '{': return MakeToken(.TokenLeftBrace);
		case '}': return MakeToken(.TokenRightBrace);
		case ';': return MakeToken(.TokenSemiColon);
		case ',': return MakeToken(.TokenComma);
		case '.': return MakeToken(.TokenDot);
		case '-': return MakeToken(.TokenMinus);
		case '+': return MakeToken(.TokenPlus);
		case '/': return MakeToken(.TokenSlash);
		case '*': return MakeToken(.TokenStar);
		case '!': return MakeToken(Match('=') ? .TokenBangEqual : .TokenBang);
		case '=': return MakeToken(Match('=') ? .TokenEqualEqual : .TokenEqual);
		case '<': return MakeToken(Match('=') ? .TokenLessEqual : .TokenLess);	
		case '>': return MakeToken(Match('=') ? .TokenGreaterEqual : .TokenGreater);
		case '"': return String();
		}

		return ErrorToken("Unexpected Character");
	}
}