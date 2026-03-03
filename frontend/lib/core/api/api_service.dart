import 'package:dio/dio.dart';
import 'package:untitled10/core/api/api_exceptions.dart';
import 'package:untitled10/core/api/dio_client.dart';


////implementation crud methods for api service
class ApiService{
  final DioClient _dioClient = DioClient();
//get
Future<dynamic>get(String endPoint)async{
  try{
    final response = await _dioClient.dio.get(endPoint);
    return response.data;
  }on DioException catch(e){
    return ApiExceptions.handleError(e);
  }
}
//post
Future<dynamic>post(String endPoint,Map<String,dynamic>body)async{
  try{
    final response = await _dioClient.dio.post(endPoint,data: body);
    return response.data;
  }on DioException catch(e){
    return ApiExceptions.handleError(e);
  }
}


//put||update
  Future<dynamic>put(String endPoint,Map<String,dynamic>body)async{
    try{
      final response = await _dioClient.dio.put(endPoint,data: body);
      return response.data;
    }on DioException catch(e){
      return ApiExceptions.handleError(e);
    }
  }

//delete
  Future<dynamic>delete(String endPoint,Map<String,dynamic>body)async{
    try{
      final response = await _dioClient.dio.delete(endPoint,data: body);
      return response.data;
    }on DioException catch(e){
      return ApiExceptions.handleError(e);
    }
  }
}
