export { DecodeError, JsonDecoder, type Decoder };

import { type Json } from './Json.ts';
import { Maybe, Just, Nothing } from 'purify-ts/Maybe';
import { Either, Left, Right } from 'purify-ts/Either';
import { List } from 'immutable';

type DecodeError =
    | { tag: 'field'; fieldName: string; error: DecodeError }
    | { tag: 'index'; index: number; error: DecodeError }
    | { tag: 'oneOf'; errors: DecodeError[] }
    | { tag: 'failure'; message: string; json: Json };

interface DecodeErrorTypeRef {
    fieldError(fieldName: string, error: DecodeError): DecodeError;
    indexError(index: number, error: DecodeError): DecodeError;
    oneOfError(errors: DecodeError[]): DecodeError;
    failureError(message: string, json: Json): DecodeError;
}

const DecodeError: DecodeErrorTypeRef = {
    fieldError: (fieldName: string, error: DecodeError): DecodeError => ({
	tag: "field",
	fieldName: fieldName,
	error: error,
    }),
    indexError: (index: number, error: DecodeError): DecodeError => ({
	tag: "index",
	index: index,
	error: error,
    }),
    oneOfError: (errors: DecodeError[]): DecodeError => ({
	tag: "oneOf",
	errors: errors,
    }),
    failureError: (message: string, json: Json): DecodeError => ({
	tag: "failure",
	message: message,
	json: json,
    })
}

interface Decoder<A> {
    decode: (json: Json) => Either<DecodeError, A>;
    map: <B>(f: (a: A) => B) => Decoder<B>;
    flatMap: <B>(next: (a: A) => Decoder<B>) => Decoder<B>;
    ap: <B>(df: Decoder<(a: A) => B>) => Decoder<B>;
}

class DecoderImpl<A> implements Decoder<A> {
    decode: (json: Json) => Either<DecodeError, A>;

    constructor(decode: (json: Json) => Either<DecodeError, A>) {
	this.decode = decode;
    }

    map: <B>(f: (a: A) => B) => Decoder<B> =
	(f) => new DecoderImpl((json) =>
	    this.decode(json).map(f));

    ap: <B>(df: Decoder<(a: A) => B>) => Decoder<B> =
	(df) => new DecoderImpl((json) =>
	    this.decode(json).ap(df.decode(json)));

    flatMap: <B>(next: (a: A) => Decoder<B>) => Decoder<B> =
	(next) => new DecoderImpl((json: Json) =>
	    this.decode(json).chain(a =>
		next(a).decode(json)));
}

interface JsonDecoderTypeRef {
    decoder<A>(decode: (json: Json) => Either<DecodeError, A>): Decoder<A>;
    pure<A>(value: A): Decoder<A>;
    string: Decoder<string>;
    number: Decoder<number>;
    bool: Decoder<boolean>;
    jsonNull<A>(a: A): Decoder<A>
    array<A>(elementDecoder: Decoder<A>): Decoder<A[]>;
    list<A>(elementDecoder: Decoder<A>): Decoder<List<A>>;
    index<A>(index: number, elementDecoder: Decoder<A>): Decoder<A>;
    maybe<A>(valueDecoder: Decoder<A>): Decoder<Maybe<A>>;
    field<A>(name: string, elementDecoder: Decoder<A>): Decoder<A>
    oneOf<A>(caseDecoders: Decoder<A>[]): Decoder<A>;
    fail<A>(message: string): Decoder<A>;
    map2<A, B, C>(f: (a: A, b: B) => C, decoderA: Decoder<A>, decoderB: Decoder<B>): Decoder<C>;
}

const curry2: <A, B, C>(f: (a: A, b: B) => C) => (a: A) => ((b: B) => C) =
  (f) => (a) => (b) => f(a, b);
    
const JsonDecoder: JsonDecoderTypeRef = {
    decoder: <A>(decode: (json: Json) => Either<DecodeError, A>) =>
	new DecoderImpl(decode),
    pure: <A>(value: A) => new DecoderImpl((_json: Json) => Right(value)),
    string: new DecoderImpl((json) => {
	if (typeof json === "string") {
	    return Right(json);
	} else {
	    return Left(DecodeError.failureError("not a string", json));
	}
    }),
    number: new DecoderImpl((json) => {
	if (typeof json === "number") {
	    return Right(json);
	} else {
	    return Left(DecodeError.failureError("not a number", json));
	}
    }),
    bool: new DecoderImpl((json) => {
	if (typeof json === "boolean") {
	    return Right(json);
	} else {
	    return Left(DecodeError.failureError("not a boolean", json));
	}
    }),

    jsonNull:
	(a) => new DecoderImpl((json) => {
	    if (typeof json === null) {
		return Right(a);
	    } else {
		return Left(DecodeError.failureError("not null", json));
	    }
	}),
    
    array:
	(elementDecoder) =>
	new DecoderImpl((json) => {
	if (Array.isArray(json)) {
	    let output = new Array(json.length);
	    let error: DecodeError | null = null;
	    for (let i = 0; i < json.length; ++i) {
		elementDecoder.decode(json[i]).caseOf({
		    Left: e => { error = e; },
		    Right: value => { output[i] = value; }});
		if (error != null)
		    return Left(DecodeError.indexError(i, error));
	    }
	    return Right(output);
	} else {
	    return Left(DecodeError.failureError("Not a json array", json));
	}
	}),

    list:
    (elementDecoder) => JsonDecoder.array(elementDecoder).map(array => List(array)),

    index:
    (index, elementDecoder) =>
	new DecoderImpl((json) => {
	    if (Array.isArray(json)) {
		if (0 <= index && index <= json.length)
		    return elementDecoder.decode(json[index])
			.mapLeft(error => DecodeError.indexError(index, error));
		else
		    return Left(DecodeError.failureError("Index out of bounds " + index, json))
	    } else {
		return Left(DecodeError.failureError("Not a JSON array", json))
	    }
	}),

    maybe:
    (valueDecoder) =>
	new DecoderImpl((json) => {
	    if (json == null)
		return Right(Nothing);
	    else
		return valueDecoder.decode(json).map(Just);
	}),

    field:
    (name, elementDecoder) =>
	new DecoderImpl((json) => {
	if (typeof(json) == 'object' && !Array.isArray(json) && json !== null) {
	    if (name in json) {
		return elementDecoder.decode(json[name])
		    .mapLeft(error => DecodeError.fieldError(name, error));
	    } else {
		return Left(DecodeError.failureError("field " + name + " not found", json));
	    }
	} else
	    return Left(DecodeError.failureError("not a JSON object", json));
    }),

    oneOf:
    (caseDecoders) =>
	new DecoderImpl((json) => {
	    let errors = new Array(caseDecoders.length)
	    for (let i = 0; i < caseDecoders.length; ++i) {
		let result = caseDecoders[i].decode(json);
		if (result.isLeft()) {
		    errors[i] = result.extract();
		} else {
		    return result;
		};
	    }
	    return Left(DecodeError.oneOfError(errors));
	}),

    fail:
    (message) => new DecoderImpl((json) => Left(DecodeError.failureError(message, json))),

    map2:
    (f, decoderA, decoderB) => decoderB.ap(decoderA.map(curry2(f)))
}
