# README

###RUTAS DE LA API
```
          Prefix Verb   URI Pattern                               Controller#Action
                        INDEX ELIMINADA
                        Creo que tiene poco sentido por ahora
        v1_users POST   /v1/users(.:format)                       v1/users#create
         v1_user GET    /v1/users/:id(.:format)                   v1/users#show
                 PATCH  /v1/users/:id(.:format)                   v1/users#update
                 PUT    /v1/users/:id(.:format)                   v1/users#update
                 DELETE /v1/users/:id(.:format)                   v1/users#destroy
v1_user_contacts GET    /v1/users/:user_id/contacts(.:format)     v1/relations#index
                 POST   /v1/users/:user_id/contacts(.:format)     v1/relations#create
 v1_user_contact GET    /v1/users/:user_id/contacts/:id(.:format) v1/relations#show
                 PATCH  /v1/users/:user_id/contacts/:id(.:format) v1/relations#update
                 PUT    /v1/users/:user_id/contacts/:id(.:format) v1/relations#update
                 DELETE /v1/users/:user_id/contacts/:id(.:format) v1/relations#destroy
```
####COMANDOS PREVIOS
```
rails db:setup -> Cuenta con unos cuantos registros de prueba
rspec
rails s
```

####1º POST 0.0.0.0:3000/V1/USERS - CREA UN USUARIO

**JSON CORRECTO** - La primera vez crea el usuario.
Pero si se continúa intentándolo con el mismo, devuelve el usuario ya registrado.
```json
{"user":{ 
	"name": "Raúl",
	"surnames": ["Cabrera","Medina"],
	"email": "rauliscoding@gmail.com",
	"phones": ["+34650278300","+34928363270"],
	"avatar": ""
	}
}
```


**JSON INCORRECTO**
>Devuelve un Validation mensaje de error.
```json
{"user":{ 
	"name": "Pepe",
	"surnames": ["Lopez","Castellano"],
	"email": "rauliscoding@gmail.com",
	"phones": ["+34650278300","+34928363270"],
	"avatar": ""
	}
}
```


####2º GET 0.0.0.0:3000/V1/USERS/:ID - MUESTRA UN USUARIO

- Comprobar la info de un usuario correcto. Por ejemplo, con el ID = 1
- Luego comprobar la info de otro usuario con un ID incorrecto = 10_000
>Mensaje de error: No puede encontrar usuario con ese id.


####3º PUT 0.0.0.0:3000/V1/USERS/1 - ACTUALIZA UN USUARIO

**JSON CORRECTO** - Ahora sólo hay un teléfono.
```json
{"user":{ 
	"name": "Raúl",
	"surnames": ["Cabrera","Medina"],
	"email": "rauliscoding@gmail.com",
	"phones": ["+34650278300"],
	"avatar": ""
	}
}
```

**JSON INCORRECTO**
```json
{"chachipiruli":{ "key": "value" } }
```
>Enhorabuena, has encontrado un bug !!!

####4º DELETE 0.0.0.0:3000/V1/USERS/:ID - BORRA UN USUARIO

- Elige para borrar la ID de un registro valido.
- Ahora, comprueba con el ID de un registro no valido.
> Mensaje de error: No puede encontrar un usuario con ese ID.

####5º GET CONTACTS - MUESTRA LOS CONTACTOS DE UN USUARIO

**GET SIN FILTROS**
0.0.0.0:3000/v1/users/1/contacts
Devuelve todos los contactos indicando sus datos y relación.

**GET BY RELACIONES**
0.0.0.0:3000/v1/users/1/contacts?relation= (family,friend,partner)
Devuelve los contactos por relación.

**GET BY NOMBRE** 
0.0.0.0:3000/v1/users/1/contacts?name=
Filtra por nombre

**GET BY APELLIDOS** 
0.0.0.0:3000/v1/users/1/contacts?surnames[]=&surnames[]=
Filtra por apellidos.

####6º POST 0.0.0.0:3000/V1/USERS/2/CONTACTS - CREA UNA RELACIÓN ENTRE USUARIOS

**CUANDO EXISTE RELACIÓN PREVIA**
> ¡¡¡ATENCIÓN
> La variable que se usa en el JSON ya no es USER, sino CONTACT.
> Y tb se le añade el tipo de RELATION.
```json
{"contact":{ 
	"name": "Raúl",
	"surnames": ["Cabrera","Medina"],
	"email": "rauliscoding@gmail.com",
	"phones": ["+34650278300"],
	"avatar": ""
	},
"relation": "family"
}
```
> Mensaje de error: Registro inválido porque..
> Si se ha lanzado el comando `rails db:seed`.
> El usuario Raúl, mantiene una relación previa con todos los usuarios.

**CON NUEVO CONTACTO**
No existe ni relación, ni usuario previos.
```json
{"contact":{ 
	"name": "Pepe",
	"surnames": ["Lopez","Castellano"],
	"email": "pepelopez@gmail.com",
	"phones": ["+34651378300","+34929263270"],
	"avatar": ""
	},
"relation": "friend"
}
```
> Nos regresa el usuario que hemos creado.
> Aprovechamos tb para checkear la relación en..
> GET 0.0.0.0:3000/v1/users/2/contacts

**CON NUEVA RELACION, PERO CON VIEJO CONTACTO**
Conseguimos los datos de otro viejo usuario en..
GET 0.0.0.0:3000/v1/users/:id
(evítate copiar su avatar)
y lo añadimos aquí abajo..
```json
{"contact":{
  -INFO AQUÍ-
  },
"relation": "partner"
}
```
Ahora antes de hacer el POST mira en..
GET 0.0.0.0:3000/v1/users/:id/contacts
..la lista de los contactos del tipo, para comprobar que no tiene relación anterior con quien lo vas a enlazar.
Una vez que hagas el POST comprobarás como el ID del registro sigue siendo el mismo.
No se han creado duplicados.
Sólo hay un registro por usuario y todos los usuarios comparten la misma info.
Ahora comprueba que la relación es bidireccional y que puedes ir a cualquiera de los usuarios para comprobar la nueva relación.
**¡SORPRESA!**

####7º GET 0.0.0.0:3000/V1/USERS/:USER_ID/CONTACTS/:ID - MUESTRA EL CONTACTO DE UN USUARIO

- Comprueba la info de uno de los contactos del usuario elegido.
- Ahora, comprueba la info de un usuario incorrecto.
Que no exista y/o que no sea contacto del usuario.
> Mensaje de error: No puede encontrar usuario con ese ID.

####8º PUT 0.0.0.0:3000/V1/USERS/:USER_ID/CONTACTS/:ID - ACTUALIZA CONTACTO Y RELACIÓN

Toma otra vez la info de un usuario.
```json
{"contact":{
  -INFO AQUÍ-
  },
"relation": "partner"
}
```
- Prueba a cambiarle algo de info.
- Ahora a la relación.
Elige: family, friend o partner

####9º DELETE 0.0.0.0:3000/V1/USERS/:USER_ID/CONTACTS/:ID - BORRA LA RELACIÓN

Sólo borra la relación que hay entre usuarios, no los registros en sí.
Aún puedes visitar las url de cada uno para comprobarlo..
0.0.0.0:3000/v1/users/:user_id

Comprueba que sucede si intentas borrar un registro que no existe.
> Mensaje de error: No puede encontrar usuario con ese id.
