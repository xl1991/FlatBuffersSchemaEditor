package maxim.zaks.generator

import maxim.zaks.flatBuffers.*
import maxim.zaks.flatBuffers.Field

class SwiftGenerator {
	
	String rootTableName
	
	public def generate(Schema schema){
		rootTableName = schema.rootType.type.name
		'''
			«FOR definitions : schema.definitions»
			«definitions.definitionReader»
			«ENDFOR»
		'''
	} 
	
	def definitionReader(Definition definition) {
		switch definition{
			Table case definition: definition.tableStructReader
		}
	}
	
	def tableStructReader(Table table) '''
		public struct «table.name»TableReader {
			private let _reader : FlatBufferReader
			private let _myOffset : ObjectOffset
			
			«table.constructorVisibility» init(reader : FlatBufferReader, offset: ObjectOffset? = nil) {
				_reader = reader
				_myOffset = offset ?? reader.rootObjectOffset
			}
			«FOR p : table.fields.indexed.map[tableStructFieldReader(it.value, it.key)]»
			«p»
			«ENDFOR»
		}
	'''
	
	def constructorVisibility(Table table) {
		if(table.name == rootTableName){
			'''public'''
		} else {
			'''private'''
		}
	}
	
	def tableStructFieldReader(Field field, int index) {
		if (field.getType.primType != null) {
			if(field.getType.primType == "string"){
				'''	
				lazy public var «field.getName» : «field.getType.generateFieldType»? = self._reader.getString(self._reader.getOffset(self._myOffset, propertyIndex: «index»))
				'''
			} else {
				'''	
				lazy public var «field.getName» : «field.getType.generateFieldType» = self._reader.get(self._myOffset, propertyIndex: «index», defaultValue: 0)
				'''
			}
		} else if(field.getType.defType != null) {
			val typeName = field.getType.generateFieldType
			'''	
				lazy public var «field.getName» : «typeName»? = {
					if let myOffset : ObjectOffset = _reader.getOffset(_myOffset, propertyIndex: «index»){
						return «typeName»(reader: _reader, offset: myOffset)
					}
					return nil
				}()
			'''
		}
	}
	
	def generateFieldType(Type fieldType) {
		if(fieldType.primType != null){
			'''«fieldType.primType.converPrimitiveType»'''
		} else if(fieldType.defType != null) {
			'''«fieldType.defType.name»TableReader'''
		} else if(fieldType.vectorType != null) {
			'''[«fieldType.vectorType.generateVectorType»]'''
		}
	}
	
	def generateVectorType(Vector vectorType){
		if(vectorType.type.primType != null){
			'''«vectorType.type.primType.converPrimitiveType»'''
		}else if(vectorType.type.defType != null){
			'''«vectorType.type.defType.name»TableReader'''
		}
	}
	
	def converPrimitiveType(String type) {
		switch type {
			case 'bool' : '''Bool'''
			case 'byte' : '''Int8'''
			case 'ubyte' : '''UInt8'''
			case 'short' : '''Int16'''
			case 'ushort' : '''UInt16'''
			case 'int' : '''Int32'''
			case 'uint' : '''UInt32'''
			case 'float' : '''Float32'''
			case 'long' : '''Int64'''
			case 'ulong' : '''UInt64'''
			case 'double' : '''Float64'''
			case 'string' : '''String'''
		}
	}
}