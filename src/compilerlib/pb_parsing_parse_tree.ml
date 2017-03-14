(*
  The MIT License (MIT)
  
  Copyright (c) 2016 Maxime Ransan <maxime.ransan@gmail.com>
  
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

*)

(** Protobuf parse tree *)

(** A field property defining its occurence
 *)
type message_field_label = [ 
  | `Optional 
  | `Required 
  | `Repeated 
  | `Nolabel  (* proto3 field which replaces required and optional *)
]

(** Oneof field fields label 

    Oneof fields have no label, they are simply choices for the 
    oneof fiel they belong to. *)
type oneof_field_label = unit 

(** message field. 
    
   Note this field is parametrized with the label type 
   so that it can be used both by normal field and one of 
   field since the only difference between the 2 is 
   the label.
 *)
type 'a field = {
  field_name : string;
  field_number : int;
  field_label : 'a;
  field_type : Pb_field_type.unresolved_t;
  field_options : Pb_option.set;
}

type message_field = message_field_label field 

type oneof_field = oneof_field_label field 

type map_field = {
  map_name : string;
  map_number : int;
  map_key_type : Pb_field_type.map_key_type;
  map_value_type : Pb_field_type.unresolved_t;
  map_options : Pb_option.set;
}

(** oneof entity *)
type oneof = {
  oneof_name : string;
  oneof_fields : oneof_field list;
}

type enum_value = {
  enum_value_name : string;
  enum_value_int : int;
}

type enum_body_content =
  | Enum_value of enum_value
  | Enum_option of Pb_option.t

type enum = {
  enum_id  : int;
  enum_name : string;
  enum_body : enum_body_content list;
} 

type extension_range_to = 
  | To_max 
  | To_number of int

type extension_range_from = int

type extension_range = 
  | Extension_single_number of int 
  | Extension_range of extension_range_from * extension_range_to

(** Body content defines all the possible consituant 
    of a message. 
  *)
type message_body_content = 
  | Message_field of message_field
  | Message_map_field of map_field 
  | Message_oneof_field of oneof 
  | Message_sub of message 
  | Message_enum of enum 
  | Message_extension of extension_range list 
  | Message_reserved of extension_range list 
  | Message_option of Pb_option.t

(** Message entity. 
 
    Note the ID is simply for uniquely (and easily) identifying a type. It is
    expected to be generated by a parser. The later compilation 
    functions expects this id to be unique.
  *)
and message = {
  id : int;
  message_name : string;
  message_body : message_body_content list;
}

type extend  = {
  id : int;
  extend_name : string;
  extend_body : message_field list;
}

type import = {
  file_name : string;
  public : bool;
}

(** Definition of a protobuffer message file. 
 *)
type proto = {
  proto_file_name : string option;
  syntax : string option;
  imports : import list;
  file_options : Pb_option.set;
  package : string option;
  messages : message list;
  enums : enum list;
  extends : extend list;
}
