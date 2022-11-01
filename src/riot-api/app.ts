// Copyright © 2022 - RIOT Insight, Inc.

import { APIGatewayEventRequestContext, APIGatewayProxyEvent, ProxyResult } from "aws-lambda";

import { AttributeValue, DynamoDBClient, GetItemCommand } from "@aws-sdk/client-dynamodb";

//const TableName = "arn:aws:dynamodb:us-east-1:256221158227:table/riot";
const TableName = "riot";
const region = "eu-west-1";
const client = new DynamoDBClient({ region });

const types = new Set(["asn", "carton", "order", "shipmentadvice", "supplier", "tunnelcarton"]);

const headers = {
  "Access-Control-Allow-Headers": "Content-Type,Authorization,X-Api-Key",
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
};

export const lambdaHandler = async (
  se: APIGatewayProxyEvent,
  context: APIGatewayEventRequestContext
): Promise<ProxyResult> => {
  console.log(`riot-api APIGatewayEvent ${se.path}`, se, context);
  const p = se.path;
  const type = p.substring(p.lastIndexOf("/") + 1);
  if (!types.has(type)) {
    return {
      statusCode: 404,
      body: `Unknown type ${type}`,
      headers
    };
  }
  const id = se.queryStringParameters?.id;
  if (!id) {
    return {
      statusCode: 400,
      body: `Missing id parameter`,
      headers
    };
  }
  const pk = `${type}#${id}`;
  const Key = { PK: { S: pk }, SK: { S: "#" } };
  const command = new GetItemCommand({ TableName, Key });
  console.log("Getting Dynamo Key", JSON.stringify(Key, null, 2));
  try {
    const response = await client.send(command);
    console.log("response", response);
    if (response.Item) {
      return {
        statusCode: 200,
        body: JSON.stringify(dynamoToObject(response.Item)),
        headers
      };
    }
    return {
      statusCode: 404,
      body: `${type} with id ${id} not found.`,
      headers
    };
  } catch (e: unknown) {
    console.log("exception", e);
    return {
      statusCode: 500,
      body: `${(e as any).message}`,
      headers
    };
  }
};

type DynamoTypes = null | string | number | boolean | string[] | object;

function dynamoToObject(d: Record<string, AttributeValue>) {
  return Object.keys(d).reduce<Record<string, DynamoTypes>>((a, k) => {
    const v = dynamoToValue(d[k]);
    if (v !== undefined) {
      a[k] = v;
    } else {
      throw new Error(`could not decode ${k} = ${JSON.stringify(d[k])}`);
    }
    return a;
  }, {});
}

function dynamoToValue(o: Record<string, any>): DynamoTypes | undefined {
  const k = Object.keys(o)[0];
  const v = o[k];
  switch (k) {
    case "S":
      return v.toString();
    case "N":
      return +v;
    case "NULL":
      return null;
    case "BOOL":
      return v == "true";
    case "SS":
      return JSON.parse(v) as string[];
    case "M":
      return dynamoToObject(v as Record<string, any>);
    case "L":
      return (v as Record<string, any>[]).map(dynamoToValue);
    case "B":
    case "NS":
    case "BS":
      break;
  }
  return undefined;
}
