import { expect, test } from 'vitest';
import { JsonDecoder, DecodeError } from './JsonDecoder.ts';
import { Maybe, Just, Nothing } from "purify-ts/Maybe";
import { Either, Left, Right } from 'purify-ts/Either'

test("string can be decoded", () => {
    expect(JsonDecoder.string.decode("foo"))
	.toStrictEqual(Right("foo"));
    expect(JsonDecoder.string.decode(42))
	.toStrictEqual(Left(DecodeError.failureError("not a string", 42)));
})

test("number can be decoded", () => {
    expect(JsonDecoder.number.decode(42))
	.toStrictEqual(Right(42));
    expect(JsonDecoder.number.decode("foo"))
	.toStrictEqual(Left(DecodeError.failureError("not a number", "foo")));
})

test("array can be decoded", () => {
    expect(JsonDecoder.array(JsonDecoder.string).decode(["foo", "bar"]))
	.toStrictEqual(Right(["foo", "bar"]));
    expect(JsonDecoder.array(JsonDecoder.string).decode([42, 23]))
	.toStrictEqual(Left(DecodeError.indexError(0, DecodeError.failureError("not a string", 42))));
})

test("array element at index can be decoded", () => {
    expect(JsonDecoder.index(0, JsonDecoder.string).decode(["foo", "bar"]))
	.toStrictEqual(Right("foo"));
    expect(JsonDecoder.index(0, JsonDecoder.string).decode([42, 23]))
	.toStrictEqual(Left(DecodeError.indexError(0, DecodeError.failureError("not a string", 42))));
})

test("nullable values be decoded", () => {
    expect(JsonDecoder.maybe(JsonDecoder.string).decode("foo"))
	.toStrictEqual(Right(Just("foo")));
    expect(JsonDecoder.maybe(JsonDecoder.string).decode(null))
	.toStrictEqual(Right(Nothing));
})


test("object fields be decoded", () => {
    expect(JsonDecoder.field("foo", JsonDecoder.string).decode( { foo: "bar" } ))
	.toStrictEqual(Right("bar"));
    expect(JsonDecoder.field("foo", JsonDecoder.string).decode( { foo: 42 } ))
	.toStrictEqual(Left(DecodeError.fieldError("foo", DecodeError.failureError("not a string", 42))));
    expect(JsonDecoder.field("foo", JsonDecoder.string).decode( { bar: 42 } ))
	.toStrictEqual(Left(DecodeError.failureError("field foo not found", { bar: 42 })));
    expect(JsonDecoder.field("foo", JsonDecoder.string).decode(42))
	.toStrictEqual(Left(DecodeError.failureError("not a JSON object", 42)));
})

test("sums can be decoded", () => {
    let d = JsonDecoder.oneOf([JsonDecoder.string.map(s => s + "bar"),
			       JsonDecoder.number.map((x: number) => (x * 2).toString())]);
    expect(d.decode("foo"))
	.toStrictEqual(Right("foobar"));
    expect(d.decode(42))
	.toStrictEqual(Right("84"));
})
    
