//
//  GGAJson.swift
//  MyIosAppTests
//
//  Created by Adrian Sanchis Serrano on 11/7/18.
//  Copyright © 2018 Pablo Apellidos. All rights reserved.
//

import UIKit
import SwiftyJSON

public class GGAJson {
    
    public static func fromJson(className:String,jsonString:String) -> JsoneableProtocol{
        let data=jsonString.data(using: .utf8)!;
        let json = try? JSON(data: data);
        return  fromJson(className: className, jsonObject: json!);
    }
    
    public static func fromJson(className:String,jsonObject:JSON) -> JsoneableProtocol{
        if(ObjectFactory.isList(className: className)){
            let listInfo=ObjectFactory<JSonBaseObject>.getListInfo(className: className);
            switch listInfo.level{
            case 1:
                return GGAJson.fromJsonLevel1Array(innertype: listInfo.innerType, jsonArray: jsonObject.arrayValue);
            case 2:
                return GGAJson.fromJsonLevel2Array(innertype: listInfo.innerType, jsonArray: jsonObject.arrayValue);
            case 3:
                return GGAJson.fromJsonLevel3Array(innertype: listInfo.innerType, jsonArray: jsonObject.arrayValue);
            default:
                print("ERROR!!");
            }
        }else{
            let typeOfObject = ObjectFactory<JSonBaseObject>.getType(className: className)
            return  GGAJson.fromJson(type:typeOfObject, jsonObject: jsonObject)
        }
        return JSonBaseObject();
    }
    
    private static func fromJsonLevel3Array<T:JsoneableProtocol>(innertype:T.Type,jsonArray:[JSON]) -> [[[T]]]
    {
        var ret : [[[T]]] = []
        for jsonObject in jsonArray{
            ret.append(GGAJson.fromJsonLevel2Array(innertype: innertype, jsonArray: jsonObject.array!));
        }
        return ret;
    }
    
    private static func fromJsonLevel2Array<T:JsoneableProtocol>(innertype:T.Type,jsonArray:[JSON]) -> [[T]]
    {
        var ret : [[T]] = []
        for jsonObject in jsonArray{
            ret.append(GGAJson.fromJsonLevel1Array(innertype: innertype, jsonArray: jsonObject.array!));
        }
        return ret;
    }
    
    private static func fromJsonLevel1Array<T:JsoneableProtocol>(innertype:T.Type,jsonArray:[JSON]) -> [T]
    {
        var ret : [T] = []
        let className = String(reflecting:innertype);
        ret.fillFromJson(json: jsonArray, className: className);
        return ret;
    }
 
    public static func fromJson<T:JsoneableProtocol>(type:T.Type,jsonString:String) -> T{
        let data=jsonString.data(using: .utf8)!;
        let json = try? JSON(data: data);
        return fromJson(type: type, jsonObject: json!);
    }
 
    
    private static func fromJson<T:JsoneableProtocol>(type:T.Type,jsonObject:JSON) -> T
    {
        let className = String(reflecting:type);
        let instance = ObjectFactory<JSonBaseObject>.createInstance(className: className);
        if((instance) != nil){  // derect inherits from JsonBaseObject
            instance!.fillFromJson(json: jsonObject);
            return instance! as! T;
        }else{
            return fromJson(className: className, jsonObject: jsonObject) as! T;
        }

    }
}
