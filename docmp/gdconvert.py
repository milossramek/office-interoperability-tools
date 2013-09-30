#!/usr/bin/python
#
# doeval.py v1.0 - 2013-09-30
#
# This script prints a document file using the GoggleDoc API
#
# Copyright (C) 2013 Michal Kaukic <misolietavec@gmail.com>
# Licensed under the GNU LGPL v3 - http://www.gnu.org/licenses/gpl.html
# - or any later version.
#

import httplib2
from apiclient.discovery import build
from oauth2client.client import SignedJwtAssertionCredentials
from apiclient import errors
from apiclient.http import MediaFileUpload
import sys
import os 

PK_FILE=os.environ['GOOGLEDOC_PK_FILE']
S_ID='218827706182-uqvco3138nrvnnjt28nk2i19v1napr9c@developer.gserviceaccount.com'

CONVERSIONS={'txt':'text/plain','rtf':'application/rtf','html':'text/html',
             'pdf':'application/pdf',
             'odt':'application/vnd.oasis.opendocument.text',
             'docx':'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
             'xlsx':'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
             'ods':'application/vnd.oasis.opendocument.spreadsheet',
             'jpeg':'image/jpeg','png':'image/png','svg':'image/svg+xml',
             'pptx':'application/vnd.openxmlformats-officedocument.presentationml.presentation',
# tieto nie su podporovane ako vystup
             'doc':'application/msword','ppt':'application/vnd.ms-powerpoint',
             'xls':'application/vnd.ms-excel',
             'odp':'application/vnd.oasis.opendocument.presentation'}

#
# ---------- Prehlad konverzii ---------------
# odt,doc,docx --> odt,docx,html,txt,rtf,pdf
# ods,xls,xlsx --> ods, xlsx,pdf
# obrazky <--> jpeg,png,svg,pdf
# ppt,pptx, -> pptx,txt,pdf


def get_credentials():
    # Load the key in PKCS 12 format that you downloaded from the Google API
    # Console when you created your Service account.
    key = file(PK_FILE, 'rb').read()

    # Create an httplib2.Http object to handle our HTTP requests and authorize it
    # with the Credentials. Note that the first parameter, service_account_name,
    # is the Email address created for the Service account. It must be the email
    # address associated with the key that was created.
    credentials = SignedJwtAssertionCredentials(S_ID, key, 'https://www.googleapis.com/auth/drive')
    http = httplib2.Http()
    http = credentials.authorize(http)
    drive_service = build('drive', 'v2', http=http)
    return drive_service,credentials


def insert_file(service, title, description, filetype, filename,parent_id=None):
    """Insert new file.

    Args:
        service: Drive API service instance.
        title: Title of the file to insert, including the extension.
        description: Description of the file to insert.
        parent_id: Parent folder's ID.
        mime_type: MIME type of the file to insert.
        filename: Filename of the file to insert.
    Returns:
        Inserted file metadata if successful, None otherwise.
    """

    mime_type=CONVERSIONS[filetype]  
    media_body = MediaFileUpload(filename, mimetype=mime_type, resumable=True)
    body = {
        'title': title,
        'description': description,
        'mimeType': mime_type
    }
    # Set the parent folder.
    if parent_id:
        body['parents'] = [{'id': parent_id}]

    try:
        file = service.files().insert(body=body,media_body=media_body,convert=True).execute()
        return file
    except errors.HttpError, error:
        print 'An error occured: %s' % error
        return None


def download_file(service, drive_file, fmt=False):
    """Download a file's content.

    Args:
        service: Drive API service instance.
        drive_file: Drive File instance.

    Returns:
        File's content if successful, None otherwise.
    """
    if fmt:
        try:
            elinks=drive_file['exportLinks']
        except KeyError:
            raise ValueError, "Cannot convert this format"
        if CONVERSIONS.has_key(fmt):
            if elinks.has_key(CONVERSIONS[fmt]):
                download_url = drive_file['exportLinks'][CONVERSIONS[fmt]]
            else:
                raise ValueError,"Unsupported conversion"
        else:
            raise ValueError,"Unknown format"  
    else:  
        download_url = drive_file.get('downloadUrl')

    if download_url:
        resp, content = service._http.request(download_url)
        if resp.status == 200:
            return content
        else:
            print 'An error occurred: %s' % resp
            return None
    else:
        # The file doesn't have any content stored on Drive.
        return None


def delete_file(service, file_id):
    """Permanently delete a file, skipping the trash.

    Args:
        service: Drive API service instance.
        file_id: ID of the file to delete.
    """
    try:
        service.files().delete(fileId=file_id).execute()
    except errors.HttpError, error:
        print 'An error occurred: %s' % error

def convert_file(service,fname,out_fmt):
    fname, in_fmt = os.path.splitext(fname)
    in_fmt = in_fmt[1:]
    if not in_fmt in CONVERSIONS:
        raise ValueError, "Unknown input format "+in_fmt+" in conversion"
    if not out_fmt in CONVERSIONS:
        raise ValueError, "Unknown output format "+out_fmt+" in conversion"
    title=fname+'.'+in_fmt
    F=insert_file(service, title, title, in_fmt, title, parent_id=None)
    DF=download_file(service, F,out_fmt)
    oname=fname+'.'+out_fmt
    file(oname,'w').write(DF)
    delete_file(service,F['id'])

def mainfunc():
    if len(sys.argv)<2:
        print "Usage: gdconvert out_fmt file"; return
    out_fmt, fname =sys.argv[1:]
    drive_service,credentials=get_credentials()
    convert_file(drive_service,fname,out_fmt)

def retrieve_all_files(service):
    """Retrieve a list of File resources.

    Args:
      service: Drive API service instance.
    Returns:
      List of File resources.
    """
    result = []
    page_token = None
    while True:
        try:
            param = {}
            if page_token:
                param['pageToken'] = page_token
            files = service.files().list(**param).execute()

            result.extend(files['items'])
            page_token = files.get('nextPageToken')
            if not page_token:
              break
        except errors.HttpError, error:
            print 'An error occurred: %s' % error
            break
    return result

def delete_all_files(service):
    LF=retrieve_all_files(service)
    for F in LF:
        delete_file(service, F['id'])
        

if __name__=="__main__":
    mainfunc()


