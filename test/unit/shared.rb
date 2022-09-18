MIN_INT = -2147483648
MAX_INT = 2147483647

MIN_INT_S = "~#{-MIN_INT}"
MAX_INT_S = "#{MAX_INT}"

WHITESPACE = %W[\t \n \r \s]
REQUIRED_ENCODING = %W[
  \t \n \r \s
    ! " # $ % & ' ( ) * + , - . /
  0 1 2 3 4 5 6 7 8 9 : ; < = > ?
  @ A B C D E F G H I J K L M N O
  P Q R S T U V W X Y Z [ \ ] ^ _
  ` a b c d e f g h i j k l m n o
  p q r s t u v w x y z { | } ~
]
