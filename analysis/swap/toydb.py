# ======================================================================

import numpy as np

# ======================================================================

class ToyDB(object):
    """
    NAME
        ToyDB

    PURPOSE
        Make a toy database, and serve up data just like Mongo does 
        (except using standard dictionaries).

    COMMENTS

    INITIALISATION
        From scratch.
    
    METHODS AND VARIABLES
        ToyDB.get_classification()
        
    BUGS

    AUTHORS
      This file is part of the Space Warps project, and is distributed 
      under the GPL v2 by the Space Warps Science Team.
      http://spacewarps.org/

    HISTORY
      2013-04-18  Started Marshall (Oxford)
    """

# ----------------------------------------------------------------------------

class ToyDB(object):
  
    def __init__(self,ambition):

        self.client = "Highest bidder"
        self.db = "Hah! This is all fake"

        self.ambition = ambition

        self.volunteers = self.populate('volunteers')
        self.subjects = self.populate('subjects')
        self.classifications = self.populate('classifications')

        return None

# ----------------------------------------------------------------------------
# Generate various tables in the database:

    def populate(self,things):

        array = []
        
        if things == 'volunteers':

            for k in range(10*self.ambition):
                Name = 'Phil'+str(k)
                
                array.append(Name)
        
        
        elif things == 'subjects':

            for j in range(100*self.ambition):
                subject = {}
                subject['ID'] = 'Image'+str(j)
                
                if np.random.rand() > 0.0:
                    subject['category'] = 'training'
                else:
                    subject['category'] = 'test'
                
                if subject['category'] == 'training':
                    if np.random.rand() > 0.5:
                        subject['kind'] = 'LENS'
                    else:
                        subject['kind'] = 'NOT'
                else:
                    subject['kind'] = 'UNKNOWN'
                
                array.append(subject)
                
                
        elif things == 'classifications':

            for i in range(1000*self.ambition):
                classification = {}
                classification['Name'] = self.pick_one('volunteers')
                
                subject = self.pick_one('subjects')
                classification['ID'] = subject['ID']
                classification['category'] = subject['category']
                classification['kind'] = subject['kind']
                classification['result'] = \
                  self.make_classification(subject=subject,volunteer=classification['Name'])
                
                array.append(classification)


        return array

# ----------------------------------------------------------------------------
# Random selection of something from its list:

    def pick_one(self,things):
    
        if things == 'volunteers':

            k = int(10*self.ambition*np.random.rand())
            something = self.volunteers[k]
        
        elif things == 'subjects':

            j = int(100*self.ambition*np.random.rand())
            something = self.subjects[j]
                
        return something
        
# ----------------------------------------------------------------------------
# Use the hidden confusion matrix of each toy volunteer to classify 
# the subject provided:

    def make_classification(self,subject=None,volunteer=None):
    
        # All toy volunteers are equally skilled! Can ignore them, and
        # just use constant P values.
        PL = 0.9
        PD = 0.6
        
        if subject['kind'] == 'LENS':
            if np.random.rand() < PL: word = 'LENS'
            else: word = 'NOT'
        elif subject['kind'] == 'NOT':
            if np.random.rand() < PD: word = 'NOT'
            else: word = 'LENS'
        
        return word

# ----------------------------------------------------------------------------
# Return a tuple of the key quantities:

    def get_classification(self,i):
        
        C = self.classifications[i]    
        
        return C['Name'],C['ID'],C['category'],C['result'],C['kind']

# ----------------------------------------------------------------------------
# Return the size of the classification table:

    def size(self):
        
        return len(self.classifications)
        
# ======================================================================

if __name__ == '__main__':
  m = ToyDB()
  # print m.subjects
  # print m.classifications
