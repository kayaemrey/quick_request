enum RequestMethod { GET, POST, PUT, PATCH, DELETE }

typedef FromJson<T> = T Function(Map<String, dynamic> json);
typedef ToJson<T> = Map<String, dynamic> Function(T model);
typedef ProgressCallback = void Function(double percent);
