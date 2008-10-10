(load "TouchJSON")

(class TestJSON is NuTestCase
     
     (- testSerializer is
        (set s (CJSONSerializer serializer))
        (assert_equal "null" (s serializeNull:nil))
        (assert_equal "123" (s serializeNumber:123))
        (assert_equal "\"one two three\"" (s serializeString:"one two three"))
        (assert_equal "[1,\"two\",3]" (s serializeArray:(array 1 "two" 3.0)))
        (assert_equal "{\"three\":[1,2,3]}"
             (s serializeDictionary:(dict three:(array 1 2 3))))
        
        ;; It seemed to me that an orthgonal API would let me do this...
        ;;(assert_equal "null" (s serializeObject:nil))
        (assert_equal "123" (s serializeObject:123))
        (assert_equal "\"one two three\"" (s serializeObject:"one two three"))
        (assert_equal "[1,\"two\",3]" (s serializeObject:(array 1 "two" 3.0)))
        (assert_equal "{\"three\":[1,2,3]}"
             (s serializeObject:(dict three:(array 1 2 3)))))
     
     (- testDeserializer is
        (set d (CJSONDeserializer deserializer))
        (assert_equal nil (d deserialize:"null"))
        (assert_equal 123 (d deserialize:"123"))
        (assert_equal "one two three" (d deserialize:"\"one two three\""))    
        (assert_equal (array 1 "two" 3.0) (d deserialize:"[1,\"two\",3]"))
        (assert_equal (dict three:(array 1 2 3)) (d deserialize:"{\"three\":[1,2,3]}")))
     
     (- testInfoInAndOut is
        (set s (CJSONSerializer serializer))
        (set d (CJSONDeserializer deserializer))
        
        (set info (NSDictionary dictionaryWithContentsOfFile:"UnitTests/Info.plist"))
        (set serialized (s serializeObject:info))
        (set info2 (d deserialize:serialized))
        (assert_equal info info2)))
