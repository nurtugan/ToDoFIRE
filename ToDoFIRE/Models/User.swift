//
//  User.swift
//  ToDoFIRE
//
//  Created by Nurtugan on 4/3/19.
//  Copyright © 2019 Nurtugan Nuraly. All rights reserved.
//

import Foundation
import Firebase

struct UserL {
  
  let uid: String
  let email: String
  
  init(user: User) {
    self.uid = user.uid
    self.email = user.email!
  }
}
